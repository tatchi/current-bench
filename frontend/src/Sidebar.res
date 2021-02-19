open! Prelude
open Components

let linkForPull = (repo_id, pull_number) => {
  "#/" ++ repo_id ++ "/pull/" ++ Belt.Int.toString(pull_number)
}

let pullToString = ((pull_number, branch)) =>
  switch branch {
  | Some(branch) => "#" ++ Belt.Int.toString(pull_number) ++ " - " ++ branch
  | None => "#" ++ Belt.Int.toString(pull_number)
  }

module PullsMenu = {
  // TODO: create a view for this ?
  module GetPulls = %graphql(`
    query GetPulls($repo_id: String!) {
      benchmarks(distinct_on: [pull_number], where: {_and: [{pull_number: {_is_null: false}, repo_id: {_eq: $repo_id}}]}, order_by: [{pull_number: desc}]) {
        pull_number
      }
    }
  `)
  @react.component
  let make = (~repo_id, ~selectedPull=?) => {
    let ({ReasonUrql.Hooks.data: data}, _) = {
      ReasonUrql.Hooks.useQuery(~query=module(GetPulls), {repo_id: repo_id})
    }
    <Column>
      <Text color=Sx.gray700 weight=#bold uppercase=true size=#md>
        {Rx.text("Pull Requests")}
      </Text>
      {switch data {
      | None => React.null
      | Some({benchmarks}) =>
        benchmarks
        ->Belt.Array.map(benchmark => benchmark.pull_number)
        ->BeltHelpers.Array.deoptionalize
        ->Belt.Array.mapWithIndex((i, pull_number) => {
          <Link
            active={selectedPull->Belt.Option.mapWithDefault(false, selectedPullNumber =>
              selectedPullNumber == pull_number
            )}
            key={string_of_int(i)}
            href={linkForPull(repo_id, pull_number)}
            text={"#" ++ string_of_int(pull_number)}
          />
        })
        ->Rx.array
      }}
      // {pulls
      // ->Belt.Array.mapWithIndex((i, pull) => {
      //   let (pull_number, _) = pull
      //   <Link
      //     active={selectedPull->Belt.Option.mapWithDefault(false, selectedPullNumber =>
      //       selectedPullNumber == pull_number
      //     )}
      //     key={string_of_int(i)}
      //     href={linkForPull(repo_id, pull)}
      //     text={pullToString(pull)}
      //   />
      // })
      // ->Rx.array}
    </Column>
  }
}

@react.component
let make = (
  ~selectedRepoId,
  ~repo_ids,
  ~onSelectRepoId,
  ~onSynchronizeToggle,
  ~synchronize,
  ~selectedPull=?,
) => {
  <Column spacing=Sx.xl2 sx=Styles.sidebarSx>
    <Components.Select
      name="repositories"
      value={selectedRepoId}
      placeholder="Select a repository"
      onChange={e => ReactEvent.Form.target(e)["value"]->onSelectRepoId}>
      {repo_ids
      ->Belt.Array.mapWithIndex((i, repo_id) =>
        <option key={string_of_int(i)} value={repo_id}> {Rx.string(repo_id)} </option>
      )
      ->Rx.array}
    </Components.Select>
    <PullsMenu repo_id=selectedRepoId ?selectedPull />
  </Column>
}
