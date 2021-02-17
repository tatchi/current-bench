%%raw(`import './App.css';`)

open! Prelude
open JsHelpers
open Components

module GetBenchmarks = %graphql(`
query ($repo_id: String!, $pull_number: Int) {
  benchmarks(where: {_and: [{repo_id: {_eq: $repo_id}, pull_number: {_eq: $pull_number}}]}) {
      repo_id
      test_name
      metrics
      commit
      branch
      pull_number
      run_at
    }
  }
`)

module GetRepoIds = %graphql(`
query GetRepoIds {
  benchmarks(distinct_on: [repo_id]) {
    repo_id
  }
}
`)

let getTestMetrics = (item: GetBenchmarks.t_benchmarks): BenchmarkTest.testMetrics => {
  {
    BenchmarkTest.name: item.test_name,
    metrics: item.metrics
    ->Belt.Option.getExn
    ->Js.Json.decodeObject
    ->Belt.Option.getExn
    ->jsDictToMap
    ->Belt.Map.String.map(v => BenchmarkTest.decodeMetricValue(v)),
    commit: item.commit,
  }
}

let getLatestMasterIndex = (~testName, benchmarks) => {
  BeltHelpers.Array.findIndexRev(benchmarks, (item: GetBenchmarks.t_benchmarks) => {
    item.pull_number == None && item.test_name == testName
  })
}

module BenchmarkResults = {
  @react.component
  let make = (~benchmarks: array<GetBenchmarks.t_benchmarks>, ~synchronize, ~repo_id) => {
    let data = benchmarks->Belt.Array.map(getTestMetrics)
    let selectionByTestName =
      data->Belt.Array.reduceWithIndex(Belt.Map.String.empty, BenchmarkTest.groupByTestName)

    let comparisonMetricsByTestName = {
      Belt.Map.String.mapWithKey(selectionByTestName, (testName, _) => {
        // TODO: Use the index load the data from master and add an annotation.
        switch getLatestMasterIndex(~testName, benchmarks) {
        | Some(idx) => Some(benchmarks[idx]->getTestMetrics)
        | None => None
        }
      })
    }

    Js.log(comparisonMetricsByTestName)

    let graphs = {
      selectionByTestName
      ->Belt.Map.String.mapWithKey((testName, testSelection) => {
        let comparisonMetrics = Belt.Map.String.getExn(comparisonMetricsByTestName, testName)
        <BenchmarkTest
          ?comparisonMetrics synchronize key={testName} data testName testSelection repo_id
        />
      })
      ->Belt.Map.String.valuesToArray
    }

    <Column spacing=Sx.xl3>
      {graphs->Rx.array(~empty=<Message text="No data for selected interval." />)}
    </Column>
  }
}

let getDefaultDateRange = {
  let hourMs = 3600.0 *. 1000.
  let dayMs = hourMs *. 24.
  () => {
    let ts2 = Js.Date.now()
    let ts1 = ts2 -. 90. *. dayMs
    (Js.Date.fromFloat(ts1), Js.Date.fromFloat(ts2))
  }
}

module Content = {
  @react.component
  let make = (
    ~selectedRepoId,
    ~repo_ids,
    ~startDate,
    ~endDate,
    ~onSelectDateRange,
    ~synchronize,
    ~onSynchronizeToggle,
    ~selectedPull=?,
  ) => {
    let ({ReasonUrql.Hooks.data: data}, _) = {
      ReasonUrql.Hooks.useQuery(
        ~query=module(GetBenchmarks),
        {repo_id: selectedRepoId, pull_number: selectedPull},
      )
    }

    <div className={Sx.make([Sx.container, Sx.d.flex, Sx.flex.wrap])}>
      <Sidebar
        selectedRepoId
        ?selectedPull
        repo_ids
        onSelectRepoId={selectedRepoId => ReasonReact.Router.push("#/" ++ selectedRepoId)}
        synchronize
        onSynchronizeToggle
      />
      <div className={Sx.make(Styles.topbarSx)}>
        <Row alignY=#center spacing=#between>
          <Link href={"https://github.com/" ++ selectedRepoId} sx=[Sx.mr.xl] icon=Icon.github />
          <Text sx=[Sx.text.bold]>
            {Rx.text(
              Belt.Option.mapWithDefault(selectedPull, "master", pull =>
                "#" ++ string_of_int(pull)
              ),
            )}
          </Text>
          <Litepicker startDate endDate sx=[Sx.w.xl5] onSelect={onSelectDateRange} />
        </Row>
      </div>
      <div className={Sx.make(Styles.mainSx)}>
        {switch data {
        | None => React.null
        | Some({benchmarks}) => <BenchmarkResults synchronize benchmarks repo_id=selectedRepoId />
        }}
      </div>
    </div>
  }
}

@react.component
let make = () => {
  let url = ReasonReact.Router.useUrl()

  let ((startDate, endDate), setDateRange) = React.useState(getDefaultDateRange)

  let onSelectDateRange = (d1, d2) => setDateRange(_ => (d1, d2))

  // Fetch benchmarks data
  let ({ReasonUrql.Hooks.response: response}, _) = {
    let startDate = Js.Date.toISOString(startDate)->Js.Json.string
    let endDate = Js.Date.toISOString(endDate)->Js.Json.string
    ReasonUrql.Hooks.useQuery(~query=module(GetRepoIds), ())
  }

  let (synchronize, setSynchronize) = React.useState(() => false)
  let onSynchronizeToggle = () => {
    setSynchronize(v => !v)
  }

  switch response {
  | Error(e) =>
    switch e.networkError {
    | Some(_e) => <div> {"Network Error"->React.string} </div>
    | None => <div> {"Unknown Error"->React.string} </div>
    }
  | Empty => <div> {"Something went wrong!"->React.string} </div>
  | Fetching => Rx.string("Loading...")
  | Data(data)
  | PartialData(data, _) =>
    let repo_ids = data.benchmarks->Belt.Array.map(benchmark => benchmark.repo_id)
    switch String.split_on_char('/', url.hash) {
    | list{""} =>
      switch Belt.Array.get(repo_ids, 0) {
      | Some(firstRepo) => {
          // If no repository is selected, this redirects to the first one.
          ReasonReact.Router.replace("#/" ++ firstRepo)
          React.null
        }
      | None => <div> {"No data were found..."->Rx.string} </div>
      }
    | list{"", orgName, repoName, ...rest} => {
        let selectedRepoId =
          repo_ids->Belt.Array.getBy(repo_id => repo_id == orgName ++ "/" ++ repoName)
        switch selectedRepoId {
        | None => <div> {"This repo does not exist!"->Rx.string} </div>
        | Some(selectedRepoId) =>
          switch rest {
          | list{"pull", pullNumberStr} =>
            switch Belt.Int.fromString(pullNumberStr) {
            | None =>
              <div> {("Pull request must be an integer. Got: " ++ pullNumberStr)->Rx.string} </div>
            | Some(selectedPull) =>
              <Content
                selectedRepoId
                repo_ids
                startDate
                endDate
                onSelectDateRange
                synchronize
                onSynchronizeToggle
                selectedPull
              />
            }
          | list{} =>
            <Content
              selectedRepoId
              repo_ids
              startDate
              endDate
              onSelectDateRange
              synchronize
              onSynchronizeToggle
            />
          | _ => <div> {("Unknown route: " ++ url.hash)->Rx.string} </div>
          }
        }
      }
    | _ => <div> {("Unknown route: " ++ url.hash)->Rx.string} </div>
    }
  }
}
