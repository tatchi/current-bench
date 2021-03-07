
/* @generated */

%bs.raw
"/* @generated */";

module Types = {
  [@ocaml.warning "-30"];
  type response_repoIds = {repo_id: string};

  type response = {repoIds: array(response_repoIds)};
  type rawResponse = response;
  type variables = unit;
};

module Internal = {
  type wrapResponseRaw;
  let wrapResponseConverter: Js.Dict.t(Js.Dict.t(Js.Dict.t(string))) = [%raw
    {json| {} |json}
  ];
  let wrapResponseConverterMap = ();
  let convertWrapResponse = v =>
    v->ReasonRelay.convertObj(
      wrapResponseConverter,
      wrapResponseConverterMap,
      Js.null,
    );

  type responseRaw;
  let responseConverter: Js.Dict.t(Js.Dict.t(Js.Dict.t(string))) = [%raw
    {json| {} |json}
  ];
  let responseConverterMap = ();
  let convertResponse = v =>
    v->ReasonRelay.convertObj(
      responseConverter,
      responseConverterMap,
      Js.undefined,
    );

  type wrapRawResponseRaw = wrapResponseRaw;
  let convertWrapRawResponse = convertWrapResponse;

  type rawResponseRaw = responseRaw;
  let convertRawResponse = convertResponse;

  let variablesConverter: Js.Dict.t(Js.Dict.t(Js.Dict.t(string))) = [%raw
    {json| {} |json}
  ];
  let variablesConverterMap = ();
  let convertVariables = v =>
    v->ReasonRelay.convertObj(
      variablesConverter,
      variablesConverterMap,
      Js.undefined,
    );
};

type queryRef;

module Utils = {};

type relayOperationNode;

type operationType = ReasonRelay.queryNode(relayOperationNode);



let node: operationType = [%raw {json| (function(){
var v0 = [
  {
    "alias": "repoIds",
    "args": [
      {
        "kind": "Literal",
        "name": "distinct_on",
        "value": [
          "repo_id"
        ]
      }
    ],
    "concreteType": "benchmarks",
    "kind": "LinkedField",
    "name": "benchmarks",
    "plural": true,
    "selections": [
      {
        "alias": null,
        "args": null,
        "kind": "ScalarField",
        "name": "repo_id",
        "storageKey": null
      }
    ],
    "storageKey": "benchmarks(distinct_on:[\"repo_id\"])"
  }
];
return {
  "fragment": {
    "argumentDefinitions": [],
    "kind": "Fragment",
    "metadata": null,
    "name": "Sidebar2_SelectRepo_Query",
    "selections": (v0/*: any*/),
    "type": "query_root",
    "abstractKey": null
  },
  "kind": "Request",
  "operation": {
    "argumentDefinitions": [],
    "kind": "Operation",
    "name": "Sidebar2_SelectRepo_Query",
    "selections": (v0/*: any*/)
  },
  "params": {
    "cacheID": "5ca51f4ac72b3e061760b84285f5f75b",
    "id": null,
    "metadata": {},
    "name": "Sidebar2_SelectRepo_Query",
    "operationKind": "query",
    "text": "query Sidebar2_SelectRepo_Query {\n  repoIds: benchmarks(distinct_on: [repo_id]) {\n    repo_id\n  }\n}\n"
  }
};
})() |json}];

include ReasonRelay.MakeLoadQuery({
    type variables = Types.variables;
    type loadedQueryRef = queryRef;
    type response = Types.response;
    type node = relayOperationNode;
    let query = node;
    let convertVariables = Internal.convertVariables;
  });
