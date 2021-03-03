open! Prelude
open Components

let linkForPull = (repoId, (pullNumber, _)) => {
  AppRouter.RepoPull({repoId: repoId, pullNumber: pullNumber})->AppRouter.path
}

let pullToString = ((pullNumber, branch)) =>
  switch branch {
  | Some(branch) => "#" ++ Belt.Int.toString(pullNumber) ++ " - " ++ branch
  | None => "#" ++ Belt.Int.toString(pullNumber)
  }

module PullsMenu = {
  module Sidebar2PullsMenuFragment = %relay(`
fragment Sidebar2_PullsMenu_query on query_root @argumentDefinitions(repoId: {type: "String!"}) {
  benchmarks(distinct_on: [pull_number], where: {_and: [{repo_id: {_eq: $repoId}}, {pull_number: {_is_null: false}}]}, order_by: [{pull_number: desc}]) {
    pull_number
    branch
  }  
}
`)
  @react.component
  let make = (~pulls, ~repoId, ~selectedPull=?) => {
    let {benchmarks} = Sidebar2PullsMenuFragment.use(pulls)

    let pulls =
      benchmarks
      ->Belt.Array.map(benchmark => benchmark.pull_number)
      ->BeltHelpers.Array.deoptionalize

    pulls
    ->Belt.Array.mapWithIndex((i, pullNumber) => {
      <Link
        sx=[Sx.pb.md]
        active={selectedPull->Belt.Option.mapWithDefault(false, selectedPullNumber =>
          selectedPullNumber == pullNumber
        )}
        key={string_of_int(i)}
        href={linkForPull(repoId, (pullNumber, None))}
        text={pullToString((pullNumber, None))}
      />
    })
    ->Rx.array
  }
}

module SelectRepo = {
  module SelectRepoFragment = %relay(`
  fragment Sidebar2_SelectRepo_query on query_root {
    benchmarks(distinct_on: [repo_id]) {
      repo_id
    }
  }
`)
  @react.component
  let make = (~repoIds, ~selectedRepoId=?, ~onSelectRepoId) => {
    let {benchmarks} = SelectRepoFragment.use(repoIds)

    <Select
      name="repositories"
      value=?selectedRepoId
      placeholder="Select a repository"
      onChange={e => ReactEvent.Form.target(e)["value"]->onSelectRepoId}>
      {benchmarks
      ->Belt.Array.mapWithIndex((i, {repo_id: repoId}) =>
        <option key={string_of_int(i)} value={repoId}> {Rx.string(repoId)} </option>
      )
      ->Rx.array}
    </Select>
  }
}

module Query = %relay(`
  query Sidebar2Query {
    ...Sidebar2_SelectRepo_query
    ...Sidebar2_PullsMenu_query
  }
`)
@react.component
let make = () => {
  let queryData = Query.use(~variables=(), ())

  let url = ReasonReactRouter.useUrl()

  let selectedRepoId = switch url.path {
  | list{orgName, repoName, ..._rest} => Some(`${orgName}/${repoName}`)
  | _ => None
  }

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
      <React.Suspense fallback={<div> {"Loading..."->Rx.string} </div>}>
        <SelectRepo
          repoIds=queryData.fragmentRefs
          ?selectedRepoId
          onSelectRepoId={repoId => AppRouter.Repo({repoId: repoId})->AppRouter.go}
        />
      </React.Suspense>
    </Column>
    <Column>
      <Text color=Sx.gray700 weight=#bold uppercase=true size=#sm>
        {Rx.text("Pull Requests")}
      </Text>
      {switch selectedRepoId {
      | Some(repoId) => <PullsMenu repoId pulls={queryData.fragmentRefs} />
      | None => Rx.text("None")
      }}
    </Column>
  </Column>
}
