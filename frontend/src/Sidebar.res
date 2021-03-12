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
query ($repoId: String!, $benchmarkName: String, $isDefaultBenchmark: Boolean!) {
  pullNumbers: benchmarks(distinct_on: [pull_number], where: {_and: [{repo_id: {_eq: $repoId}}, {pull_number: {_is_null: false}}, {benchmark_name: {_is_null: $isDefaultBenchmark, _eq: $benchmarkName}}]}, order_by: [{pull_number: desc}]) {
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
  let makesVariables = (~benchmarkName=?, ~repoId): GetRepoPulls.t_variables => {
    let isDefaultBenchmark = Belt.Option.isNone(benchmarkName)
    {
      repoId: repoId,
      benchmarkName: benchmarkName,
      isDefaultBenchmark: isDefaultBenchmark,
    }
  }

  @react.component
  let make = (~repoId, ~benchmarkName=?, ~selectedPull=?) => {
    let ({ReasonUrql.Hooks.response: response}, _) = {
      ReasonUrql.Hooks.useQuery(
        ~query=module(GetRepoPulls),
        makesVariables(~repoId, ~benchmarkName?),
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
          href={linkForPull(repoId, benchmarkName, pull)}
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

    Js.log(selectedBenchmarkName)

    switch response {
    | Empty => <div> {"Something went wrong!"->Rx.text} </div>
    | Error({networkError: Some(_)}) => <div> {"Network Error"->Rx.text} </div>
    | Error({networkError: None}) => <div> {"Unknown Error"->Rx.text} </div>
    | Fetching => Rx.text("Loading...")
    | Data(data)
    | PartialData(data, _) =>
      let benchmarkNames = data.benchmarkNames->Belt.Array.map(obj => obj.benchmark_name)

      benchmarkNames
      ->Belt.Array.mapWithIndex((i, benchmarkName) => {
        <Link
          sx=[Sx.pb.md]
          active={selectedBenchmarkName == benchmarkName}
          key={string_of_int(i)}
          href={AppRouter.RepoBenchmark({
            repoId: repoId,
            benchmarkName: benchmarkName,
          })->AppRouter.path}
          text={benchmarkName->Belt.Option.getWithDefault("default")}
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
      {switch selectedRepoId {
      | Some(repoId) => <PullsMenu repoId benchmarkName=?selectedBenchmarkName ?selectedPull />
      | None => Rx.text("None")
      }}
    </Column>
  </Column>
}
