type route =
  | Main
  | Repo({repoId: string}) // Default benchmark on master
  | RepoBenchmark({repoId: string, benchmarkName: string}) // benchmarkName on master
  | RepoPull({repoId: string, pullNumber: int}) // Default benchmark on pullNumber
  | RepoBenchmarkWithPull({repoId: string, benchmarkName: string, pullNumber: int}) // benchmarkName on pullNumber

type error = {
  path: list<string>,
  reason: string,
}

let route = (url: ReasonReactRouter.url) =>
  switch url.path {
  | list{} => Ok(Main)
  | list{orgName, repoName} => Ok(Repo({repoId: orgName ++ "/" ++ repoName})) //default benchmark + master
  | list{orgName, repoName, "benchmark", benchmarkName} =>
    Ok(RepoBenchmark({repoId: orgName ++ "/" ++ repoName, benchmarkName: benchmarkName}))
  | list{orgName, repoName, "pull", pullNumberStr} =>
    switch Belt.Int.fromString(pullNumberStr) {
    | Some(pullNumber) =>
      Ok(
        RepoPull({
          repoId: orgName ++ "/" ++ repoName,
          pullNumber: pullNumber,
        }),
      )
    | None => Error({path: url.path, reason: "Invalid pull number: " ++ pullNumberStr})
    }
  | list{orgName, repoName, "benchmark", benchmarkName, "pull", pullNumberStr} =>
    switch Belt.Int.fromString(pullNumberStr) {
    | Some(pullNumber) =>
      Ok(
        RepoBenchmarkWithPull({
          repoId: orgName ++ "/" ++ repoName,
          benchmarkName: benchmarkName,
          pullNumber: pullNumber,
        }),
      )
    | None => Error({path: url.path, reason: "Invalid pull number: " ++ pullNumberStr})
    }
  | _ => Error({path: url.path, reason: "Unknown route: /" ++ String.concat("/", url.path)})
  }

let path = route =>
  switch route {
  | Main => "/"
  | Repo({repoId}) => "/" ++ repoId
  | RepoBenchmark({repoId, benchmarkName}) => "/" ++ repoId ++ "/benchmark/" ++ benchmarkName
  | RepoPull({repoId, pullNumber}) => "/" ++ repoId ++ "/pull/" ++ Belt.Int.toString(pullNumber)
  | RepoBenchmarkWithPull({repoId, pullNumber, benchmarkName}) =>
    "/" ++ repoId ++ "/benchmark/" ++ benchmarkName ++ "/pull/" ++ Belt.Int.toString(pullNumber)
  }

let useRoute = () => ReasonReactRouter.useUrl()->route

let go = route => ReasonReact.Router.push(path(route))
