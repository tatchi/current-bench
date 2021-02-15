open! Prelude
open Components

let linkForPull = (repo_id, (pull_number, _)) => {
  "#/" ++ repo_id ++ "/pull/" ++ Belt.Int.toString(pull_number)
}

let pullToString = ((pull_number, branch)) =>
  switch branch {
  | Some(branch) => "#" ++ Belt.Int.toString(pull_number) ++ " - " ++ branch
  | None => "#" ++ Belt.Int.toString(pull_number)
  }

%graphql(`
  fragment PullsMenu_fragment on query_root @argumentDefinitions(repo_id: {type: "String!"}){
    pullsMenuData: benchmarks(distinct_on:[pull_number], where: {_and: [{repo_id: {_eq: $repo_id}, pull_number: {_is_null: false}}]}) {
      pull_number
    }
  }
`)

module PullsMenu = {
  @react.component
  let make = (~data: PullsMenu_fragment.t, ~repo_id, ~selectedPull=?) => {
    <Column>
      <Text color=Sx.gray700 weight=#bold uppercase=true size=#md>
        {Rx.text("Pull Requests")}
      </Text>
      {data.pullsMenuData
      ->Belt.Array.map(d => d.pull_number)
      ->BeltHelpers.Array.deoptionalize
      ->Belt.Array.mapWithIndex((i, pull_number) => {
        <Link
          active={selectedPull->Belt.Option.mapWithDefault(false, selectedPullNumber =>
            selectedPullNumber == pull_number
          )}
          key={string_of_int(i)}
          href={linkForPull(repo_id, (pull_number, None))}
          text={pullToString((pull_number, None))}
        />
      })
      ->Rx.array}
    </Column>
  }
}
%graphql(`
  fragment SelectRepo_fragment on query_root {
    selectRepoData: benchmarks(distinct_on: [repo_id]) {
      repo_id
    }
  }
`)

module SelectRepo = {
  @react.component
  let make = (~data: SelectRepo_fragment.t, ~selectedRepoId, ~onSelectRepoId) => {
    <Components.Select
      name="repositories"
      value={selectedRepoId}
      placeholder="Select a repository"
      onChange={e => ReactEvent.Form.target(e)["value"]->onSelectRepoId}>
      {data.selectRepoData
      ->Belt.Array.mapWithIndex((i, item) =>
        <option key={string_of_int(i)} value={item.repo_id}> {Rx.string(item.repo_id)} </option>
      )
      ->Rx.array}
    </Components.Select>
  }
}

%graphql(`
  fragment Sidebar_fragment on query_root @argumentDefinitions(repo_id: {type: "String!"}) {
    a: benchmarks(limit: 1){
      repo_id
    }
   ...SelectRepo_fragment
   ...PullsMenu_fragment @arguments(repo_id: $repo_id)
  }
`)

@react.component
let make = (
  ~data: Sidebar_fragment.t,
  ~selectedRepoId,
  ~onSelectRepoId,
  ~onSynchronizeToggle,
  ~synchronize,
  ~selectedPull=?,
) => {
  <Column spacing=Sx.xl2 sx=Styles.sidebarSx>
    <SelectRepo selectedRepoId onSelectRepoId data=data.selectRepo_fragment />
    // <Components.Select
    //   name="repositories"
    //   value={selectedRepoId}
    //   placeholder="Select a repository"
    //   onChange={e => ReactEvent.Form.target(e)["value"]->onSelectRepoId}>
    //   {data
    //   ->Belt.Array.mapWithIndex((i, item) =>
    //     <option key={string_of_int(i)} value={item.repo_id}> {Rx.string(item.repo_id)} </option>
    //   )
    //   ->Rx.array}
    // </Components.Select>
    <PullsMenu data=data.pullsMenu_fragment repo_id=selectedRepoId ?selectedPull />
  </Column>
}
