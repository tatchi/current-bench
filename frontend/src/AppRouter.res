type route =
  | Main
  | Repo({repoId: string})
  | RepoBenchmark({repoId: string, benchmarkName: string})
  | RepoPull({repoId: string, benchmarkName: string, pullNumber: int})

type error = {
  path: list<string>,
  reason: string,
}

let route = (url: ReasonReactRouter.url) =>
  switch url.path {
  | list{} => Ok(Main)
  | list{orgName, repoName} => Ok(Repo({repoId: orgName ++ "/" ++ repoName}))
  // | list{orgName, repoName, "benchmark", "default"} =>
  //   Ok(RepoBenchmark({repoId: orgName ++ "/" ++ repoName, benchmarkName: None}))
  | list{orgName, repoName, "benchmark", benchmarkName} =>
    Ok(RepoBenchmark({repoId: orgName ++ "/" ++ repoName, benchmarkName: benchmarkName}))
  // | list{orgName, repoName, "benchmark", "default", "pull", pullNumberStr} =>
  //   switch Belt.Int.fromString(pullNumberStr) {
  //   | Some(pullNumber) =>
  //     Ok(
  //       RepoPull({repoId: orgName ++ "/" ++ repoName, benchmarkName: None, pullNumber: pullNumber}),
  //     )
  //   | None => Error({path: url.path, reason: "Invalid pull number: " ++ pullNumberStr})
  //   }
  | list{orgName, repoName, "benchmark", benchmarkName, "pull", pullNumberStr} =>
    switch Belt.Int.fromString(pullNumberStr) {
    | Some(pullNumber) =>
      Ok(
        RepoPull({
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
  // | RepoPull({repoId, pullNumber, benchmarkName: None}) =>
  //   "/" ++ repoId ++ "/benchmark/default" ++ "/pull/" ++ Belt.Int.toString(pullNumber)
  | RepoPull({repoId, pullNumber, benchmarkName}) =>
    "/" ++ repoId ++ "/benchmark/" ++ benchmarkName ++ "/pull/" ++ Belt.Int.toString(pullNumber)
  }

let useRoute = () => ReasonReactRouter.useUrl()->route

let go = route => ReasonReact.Router.push(path(route))
