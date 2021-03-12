type route =
  | Main
  | Repo({repoId: string})
  | RepoBenchmark({repoId: string, benchmarkName: option<string>})
  | RepoPull({repoId: string, benchmarkName: option<string>, pullNumber: int})

type error = {
  path: list<string>,
  reason: string,
}

let route = (url: ReasonReactRouter.url) =>
  switch url.path {
  | list{} => Ok(Main)
  | list{orgName, repoName} => Ok(Repo({repoId: orgName ++ "/" ++ repoName}))
  | list{orgName, repoName, "benchmark", benchmarkName} =>
    let benchmarkName = switch benchmarkName {
    | "default" => None
    | benchmarkName => Some(benchmarkName)
    }
    Ok(RepoBenchmark({repoId: orgName ++ "/" ++ repoName, benchmarkName: benchmarkName}))
  | list{orgName, repoName, "benchmark", benchmarkName, "pull", pullNumberStr} =>
    let benchmarkName = switch benchmarkName {
    | "default" => None
    | benchmarkName => Some(benchmarkName)
    }

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
  | RepoBenchmark({repoId, benchmarkName}) =>
    "/" ++ repoId ++ "/benchmark/" ++ benchmarkName->Belt.Option.getWithDefault("default")
  | RepoPull({repoId, pullNumber, benchmarkName}) =>
    "/" ++
    repoId ++
    "/benchmark/" ++
    benchmarkName->Belt.Option.getWithDefault("default") ++
    "/pull/" ++
    Belt.Int.toString(pullNumber)
  }

let useRoute = () => ReasonReactRouter.useUrl()->route

let go = route => ReasonReact.Router.push(path(route))
