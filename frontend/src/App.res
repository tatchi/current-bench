%%raw(`import './App.css';`)

open! Prelude
open JsHelpers
open Components

%graphql(`
  fragment Benchmark on benchmarks {
    repo_id
    test_name
    metrics
    commit
    branch
    pull_number
    run_at
  }
`)

module GetBenchmarksForMaster = %graphql(`
  query ($repo_id: String!) {
    benchmarks(where: {_and: [{repo_id: {_eq: $repo_id}}, {pull_number: {_is_null: true}}]}) {
      ...Benchmark
    }
  }
`)
module GetBenchmarksForPull = %graphql(`
  query ($repo_id: String!, $pull_number: Int!) {
    benchmarks(where: {_and: [{repo_id: {_eq: $repo_id}}, {_or: [{pull_number: {_eq: $pull_number}}, {pull_number: {_is_null: true}}]}]}) {
      ...Benchmark
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

module PullCompare = Belt.Id.MakeComparable({
  type t = (int, option<string>)
  let cmp = (a, b) => -compare(a, b)
})

let decodeRunAt = runAt => runAt->Js.Json.decodeString->Belt.Option.map(Js.Date.fromString)

let decodeMetrics = metrics =>
  metrics
  ->Belt.Option.getExn
  ->Js.Json.decodeObject
  ->Belt.Option.getExn
  ->jsDictToMap
  ->Belt.Map.String.map(v => BenchmarkTest.decodeMetricValue(v))

let getTestMetrics = (item: Benchmark.t): BenchmarkTest.testMetrics => {
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
  BeltHelpers.Array.findIndexRev(benchmarks, (item: Benchmark.t) => {
    item.pull_number == None && item.test_name == testName
  })
}

module BenchmarkView = {
  @react.component
  let make = (
    ~repo_id,
    ~benchmarkDataByTestName: BenchmarkData.byTestName,
    ~comparisonBenchmarkDataByTestName=Belt.Map.String.empty,
  ) => {
    let graphs = {
      benchmarkDataByTestName
      ->Belt.Map.String.mapWithKey((testName, dataByMetricName) => {
        let comparison = Belt.Map.String.getWithDefault(
          comparisonBenchmarkDataByTestName,
          testName,
          Belt.Map.String.empty,
        )
        <BenchmarkTest key={testName} repo_id testName dataByMetricName comparison />
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

let getBenchmarData = (~benchmarks: array<Benchmark.t>) =>
  benchmarks->Belt.Array.reduce(BenchmarkData.empty, (acc, item) => {
    item.metrics
    ->decodeMetrics
    ->Belt.Map.String.reduce(acc, (acc, metricName, value) => {
      BenchmarkData.add(
        acc,
        ~pullNumber=item.pull_number,
        ~testName=item.test_name,
        ~metricName,
        ~runAt=item.run_at->decodeRunAt->Belt.Option.getExn,
        ~commit=item.commit,
        ~value,
      )
    })
  })

module BencharkViewForMaster = {
  @react.component
  let make = (~repo_id) => {
    let ({ReasonUrql.Hooks.data: data, ReasonUrql.Hooks.fetching: fetching}, _) = {
      ReasonUrql.Hooks.useQuery(~query=module(GetBenchmarksForMaster), {repo_id: repo_id})
    }
    switch (fetching, data) {
    | (false, Some({benchmarks})) => {
        let benchmarkData = getBenchmarData(~benchmarks)
        let benchmarkDataByTestName = BenchmarkData.forPullNumber(benchmarkData, None)
        <BenchmarkView repo_id benchmarkDataByTestName />
      }
    | _ => React.null
    }
  }
}
module BencharkViewForPull = {
  @react.component
  let make = (~repo_id, ~pull_number) => {
    let ({ReasonUrql.Hooks.data: data, ReasonUrql.Hooks.fetching: fetching}, _) = {
      ReasonUrql.Hooks.useQuery(
        ~query=module(GetBenchmarksForPull),
        {repo_id: repo_id, pull_number: pull_number},
      )
    }
    switch (fetching, data) {
    | (false, Some({benchmarks})) => {
        let benchmarkData = getBenchmarData(~benchmarks)
        let benchmarkDataByTestName = BenchmarkData.forPullNumber(benchmarkData, Some(pull_number))
        let comparisonBenchmarkDataByTestName = BenchmarkData.forPullNumber(benchmarkData, None)
        <BenchmarkView repo_id benchmarkDataByTestName comparisonBenchmarkDataByTestName />
      }
    | _ => React.null
    }
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
        {switch selectedPull {
        | None => <BencharkViewForMaster repo_id=selectedRepoId />
        | Some(pull_number) => <BencharkViewForPull repo_id=selectedRepoId pull_number />
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
                selectedPull
                startDate
                endDate
                onSelectDateRange
                synchronize
                onSynchronizeToggle
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
