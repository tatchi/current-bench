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
  module Sidebar2PullsMenuQuery = %relay(`
query Sidebar2_PullsMenu_Query($repoId: String!) {
  benchmarks(
    distinct_on: [pull_number]
    where: {
      _and: [
        { repo_id: { _eq: $repoId } }
        { pull_number: { _is_null: false } }
      ]
    }
    order_by: [{ pull_number: desc }]
  ) {
    pull_number
    branch
  }
}
`)
  @react.component
  let make = (~repoId, ~selectedPull=?) => {
    let {benchmarks} = Sidebar2PullsMenuQuery.use(~variables={repoId: repoId}, ())
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
  module SelectRepoQuery = %relay(`
  query Sidebar2_SelectRepo_Query {
    repoIds: benchmarks(distinct_on: [repo_id]) {
      repo_id
    }
  }
`)
  @react.component
  let make = (~selectedRepoId=?, ~onSelectRepoId) => {
    let {repoIds} = SelectRepoQuery.use(~variables=(), ())

    <Select
      name="repositories"
      value=?selectedRepoId
      placeholder="Select a repository"
      onChange={e => ReactEvent.Form.target(e)["value"]->onSelectRepoId}>
      {repoIds
      ->Belt.Array.mapWithIndex((i, {repo_id: repoId}) =>
        <option key={string_of_int(i)} value={repoId}> {Rx.string(repoId)} </option>
      )
      ->Rx.array}
    </Select>
  }
}

@react.component
let make = (~selectedRepoId=?) => {
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
      <React.Suspense fallback={<div> {"Select loading..."->Rx.string} </div>}>
        <SelectRepo
          ?selectedRepoId onSelectRepoId={repoId => AppRouter.Repo({repoId: repoId})->AppRouter.go}
        />
      </React.Suspense>
    </Column>
    <Column>
      <Text color=Sx.gray700 weight=#bold uppercase=true size=#sm>
        {Rx.text("Pull Requests")}
      </Text>
      {switch selectedRepoId {
      | Some(repoId) =>
        <React.Suspense fallback={<div> {"pulls loading..."->Rx.string} </div>}>
          <PullsMenu repoId />
        </React.Suspense>
      | _ => Rx.text("None")
      }}
    </Column>
  </Column>
}
