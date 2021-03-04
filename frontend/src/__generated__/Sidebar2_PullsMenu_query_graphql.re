
/* @generated */

%bs.raw
"/* @generated */";

module Types = {
  [@ocaml.warning "-30"];
  type response_benchmarks = {
    pull_number: option(int),
    branch: option(string),
  };

  type response = {benchmarks: array(response_benchmarks)};
  type rawResponse = response;
  type refetchVariables = {repoId: option(string)};
  let makeRefetchVariables = (~repoId=?, ()): refetchVariables => {
    repoId: repoId,
  };
  type variables = {repoId: string};
};

module Internal = {
  type wrapResponseRaw;
  let wrapResponseConverter: Js.Dict.t(Js.Dict.t(Js.Dict.t(string))) = [%raw
    {json| {"__root":{"benchmarks_branch":{"n":""},"benchmarks_pull_number":{"n":""}}} |json}
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
    {json| {"__root":{"benchmarks_branch":{"n":""},"benchmarks_pull_number":{"n":""}}} |json}
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

module Utils = {
  open Types;
  let makeVariables = (~repoId): variables => {repoId: repoId};
};

type relayOperationNode;

type operationType = ReasonRelay.queryNode(relayOperationNode);



let node: operationType = [%raw {json| (function(){
var v0 = [
  {
    "defaultValue": null,
    "kind": "LocalArgument",
    "name": "repoId"
  }
],
v1 = [
  {
    "alias": null,
    "args": [
      {
        "kind": "Literal",
        "name": "distinct_on",
        "value": [
          "pull_number"
        ]
      },
      {
        "kind": "Literal",
        "name": "order_by",
        "value": [
          {
            "pull_number": "desc"
          }
        ]
      },
      {
        "fields": [
          {
            "items": [
              {
                "fields": [
                  {
                    "fields": [
                      {
                        "kind": "Variable",
                        "name": "_eq",
                        "variableName": "repoId"
                      }
                    ],
                    "kind": "ObjectValue",
                    "name": "repo_id"
                  }
                ],
                "kind": "ObjectValue",
                "name": "_and.0"
              },
              {
                "kind": "Literal",
                "name": "_and.1",
                "value": {
                  "pull_number": {
                    "_is_null": false
                  }
                }
              }
            ],
            "kind": "ListValue",
            "name": "_and"
          }
        ],
        "kind": "ObjectValue",
        "name": "where"
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
        "name": "pull_number",
        "storageKey": null
      },
      {
        "alias": null,
        "args": null,
        "kind": "ScalarField",
        "name": "branch",
        "storageKey": null
      }
    ],
    "storageKey": null
  }
];
return {
  "fragment": {
    "argumentDefinitions": (v0/*: any*/),
    "kind": "Fragment",
    "metadata": null,
    "name": "Sidebar2_PullsMenu_Query",
    "selections": (v1/*: any*/),
    "type": "query_root",
    "abstractKey": null
  },
  "kind": "Request",
  "operation": {
    "argumentDefinitions": (v0/*: any*/),
    "kind": "Operation",
    "name": "Sidebar2_PullsMenu_Query",
    "selections": (v1/*: any*/)
  },
  "params": {
    "cacheID": "d575410f42c94afde10db4b25a971385",
    "id": null,
    "metadata": {},
    "name": "Sidebar2_PullsMenu_Query",
    "operationKind": "query",
    "text": "query Sidebar2_PullsMenu_Query(\n  $repoId: String!\n) {\n  benchmarks(distinct_on: [pull_number], where: {_and: [{repo_id: {_eq: $repoId}}, {pull_number: {_is_null: false}}]}, order_by: [{pull_number: desc}]) {\n    pull_number\n    branch\n  }\n}\n"
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
