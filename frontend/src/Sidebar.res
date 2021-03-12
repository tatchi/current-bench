open! Prelude
open Components

let linkForPull = (repoId, benchmarkName, (pullNumber, _)) => {
  AppRouter.RepoPull({
    repoId: repoId,
    benchmarkName: benchmarkName,
    pullNumber: pullNumber,
  })->AppRouter.path
}

let pullToString = ((pullNumber, branch)) =>
  switch branch {
  | Some(branch) => "#" ++ Belt.Int.toString(pullNumber) ++ " - " ++ branch
  | None => "#" ++ Belt.Int.toString(pullNumber)
  }

module GetRepoPulls = %graphql(`
query ($repoId: String!, $benchmarkName: String) {
  pullNumbers: benchmarks(distinct_on: [pull_number], where: {_and: [{repo_id: {_eq: $repoId}}, {pull_number: {_is_null: false}}, {benchmark_name: {_eq: $benchmarkName}}]}, order_by: [{pull_number: desc}]) {
    pull_number
    branch
  }
}
`)

module GetRepoBenchmarkNames = %graphql(`
query ($repoId: String!) {
  benchmarkNames: benchmarks(distinct_on: [benchmark_name], where: {repo_id: {_eq: $repoId}}, order_by: [{benchmark_name: asc_nulls_first}]) {
    benchmark_name
  }
}
`)

module PullsMenu = {
  @react.component
  let make = (~repoId, ~benchmarkName=?, ~selectedPull=?) => {
    let ({ReasonUrql.Hooks.response: response}, _) = {
      ReasonUrql.Hooks.useQuery(
        ~query=module(GetRepoPulls),
        {
          repoId: repoId,
          benchmarkName: benchmarkName,
        },
      )
    }

    switch response {
    | Empty => <div> {"Something went wrong!"->Rx.text} </div>
    | Error({networkError: Some(_)}) => <div> {"Network Error"->Rx.text} </div>
    | Error({networkError: None}) => <div> {"Unknown Error"->Rx.text} </div>
    | Fetching => Rx.text("Loading...")
    | Data(data)
    | PartialData(data, _) =>
      let pulls =
        data.pullNumbers->Belt.Array.map(obj => (obj.pull_number->Belt.Option.getExn, obj.branch))

      pulls
      ->Belt.Array.mapWithIndex((i, pull) => {
        let (pullNumber, _) = pull
        <Link
          sx=[Sx.pb.md]
          active={selectedPull->Belt.Option.mapWithDefault(false, selectedPullNumber =>
            selectedPullNumber == pullNumber
          )}
          key={string_of_int(i)}
          href={linkForPull(
            repoId,
            benchmarkName->Belt.Option.getWithDefault("default"),
            pull,
          )}
          text={pullToString(pull)}
        />
      })
      ->Rx.array
    }
  }
}
module BenchmarksMenu = {
  @react.component
  let make = (~repoId, ~selectedBenchmarkName=?) => {
    let ({ReasonUrql.Hooks.response: response}, _) = {
      ReasonUrql.Hooks.useQuery(
        ~query=module(GetRepoBenchmarkNames),
        {
          repoId: repoId,
        },
      )
    }

    switch response {
    | Empty => <div> {"Something went wrong!"->Rx.text} </div>
    | Error({networkError: Some(_)}) => <div> {"Network Error"->Rx.text} </div>
    | Error({networkError: None}) => <div> {"Unknown Error"->Rx.text} </div>
    | Fetching => Rx.text("Loading...")
    | Data(data)
    | PartialData(data, _) =>
      let benchmarkNames =
        data.benchmarkNames->Belt.Array.map(obj =>
          obj.benchmark_name->Belt.Option.getWithDefault("default")
        )

      benchmarkNames
      ->Belt.Array.mapWithIndex((i, benchmarkName) => {
        <Link
          sx=[Sx.pb.md]
          active={selectedBenchmarkName->Belt.Option.mapWithDefault(false, selectedBenchmarkName =>
            selectedBenchmarkName == benchmarkName
          )}
          key={string_of_int(i)}
          href={AppRouter.RepoBenchmark({
            repoId: repoId,
            benchmarkName: benchmarkName,
          })->AppRouter.path}
          text={benchmarkName}
        />
      })
      ->Rx.array
    }
  }
}

@react.component
let make = (
  ~repoIds,
  ~selectedRepoId=?,
  ~onSelectRepoId,
  ~selectedPull=?,
  ~selectedBenchmarkName=?,
) => {
  <Column
    spacing=Sx.xl
    sx=[
      Sx.t.zero,
      Sx.h.screen,
      Sx.sticky,
      Sx.w.xl5,
      Sx.borderR.xs,
      Sx.borderR.color(Sx.gray300),
      Sx.overflowY.scroll,
      Sx.overflowX.hidden,
      Sx.bg.color(Sx.white),
      Sx.px.xl,
      Sx.py.lg,
    ]>
    <Row spacing=Sx.lg alignY=#center>
      <Link
        href="/"
        icon={<Icon sx=[Sx.unsafe("width", "36px"), Sx.mr.lg] svg=Icon.ocaml />}
        sx=[Sx.text.bold, Sx.text.xl, Sx.hover([Sx.text.color(Sx.gray900)])]
        text="Benchmarks"
      />

    </Row>
    <Column>
      <Text sx=[Sx.mb.md] color=Sx.gray700 weight=#bold uppercase=true size=#sm>
        {Rx.text("Repositories")}
      </Text>
      <Select
        name="repositories"
        value=?selectedRepoId
        placeholder="Select a repository"
        onChange={e => ReactEvent.Form.target(e)["value"]->onSelectRepoId}>
        {repoIds
        ->Belt.Array.mapWithIndex((i, repoId) =>
          <option key={string_of_int(i)} value={repoId}> {Rx.string(repoId)} </option>
        )
        ->Rx.array}
      </Select>
    </Column>
    <Column>
      <Text color=Sx.gray700 weight=#bold uppercase=true size=#sm> {Rx.text("Benchmarks")} </Text>
      {switch selectedRepoId {
      | Some(repoId) => <BenchmarksMenu repoId ?selectedBenchmarkName />
      | None => Rx.text("None")
      }}
    </Column>
    <Column>
      <Text color=Sx.gray700 weight=#bold uppercase=true size=#sm>
        {Rx.text("Pull Requests")}
      </Text>
      {switch (selectedRepoId, selectedBenchmarkName) {
      | (Some(repoId), Some(benchmarkName)) =>
        <PullsMenu
          repoId
          benchmarkName=?{benchmarkName == "default" ? None : Some(benchmarkName)}
          ?selectedPull
        />
      | _ => Rx.text("None")
      }}
    </Column>
  </Column>
}
