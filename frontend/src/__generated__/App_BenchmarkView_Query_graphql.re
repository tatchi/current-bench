
/* @generated */

%bs.raw
"/* @generated */";

module Types = {
  [@ocaml.warning "-30"];
  type response_benchmarks = {
    fragmentRefs:
      ReasonRelay.fragmentRefs([ | `App_BenchmarkMetrics_Fragment]),
  }
  and response_comparisonBenchmarks = {
    fragmentRefs:
      ReasonRelay.fragmentRefs([ | `App_BenchmarkMetrics_Fragment]),
  };

  type response = {
    benchmarks: array(response_benchmarks),
    comparisonBenchmarks: array(response_comparisonBenchmarks),
  };
  type rawResponse = response;
  type refetchVariables = {
    repoId: option(string),
    pullNumber: option(int),
  };
  let makeRefetchVariables = (~repoId=?, ~pullNumber=?, ()): refetchVariables => {
    repoId,
    pullNumber,
  };
  type variables = {
    repoId: string,
    pullNumber: int,
  };
};

module Internal = {
  type wrapResponseRaw;
  let wrapResponseConverter: Js.Dict.t(Js.Dict.t(Js.Dict.t(string))) = [%raw
    {json| {"__root":{"benchmarks":{"f":""},"comparisonBenchmarks":{"f":""}}} |json}
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
    {json| {"__root":{"benchmarks":{"f":""},"comparisonBenchmarks":{"f":""}}} |json}
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
  let makeVariables = (~repoId, ~pullNumber): variables => {
    repoId,
    pullNumber,
  };
};

type relayOperationNode;

type operationType = ReasonRelay.queryNode(relayOperationNode);



let node: operationType = [%raw {json| (function(){
var v0 = {
  "defaultValue": null,
  "kind": "LocalArgument",
  "name": "pullNumber"
},
v1 = {
  "defaultValue": null,
  "kind": "LocalArgument",
  "name": "repoId"
},
v2 = {
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
  "name": "_and.1"
},
v3 = [
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
                    "variableName": "pullNumber"
                  }
                ],
                "kind": "ObjectValue",
                "name": "pull_number"
              }
            ],
            "kind": "ObjectValue",
            "name": "_and.0"
          },
          (v2/*: any*/)
        ],
        "kind": "ListValue",
        "name": "_and"
      }
    ],
    "kind": "ObjectValue",
    "name": "where"
  }
],
v4 = [
  {
    "alias": null,
    "args": null,
    "kind": "ScalarField",
    "name": "run_at",
    "storageKey": null
  },
  {
    "alias": null,
    "args": null,
    "kind": "ScalarField",
    "name": "commit",
    "storageKey": null
  },
  {
    "alias": null,
    "args": null,
    "kind": "ScalarField",
    "name": "test_name",
    "storageKey": null
  },
  {
    "alias": null,
    "args": null,
    "kind": "ScalarField",
    "name": "metrics",
    "storageKey": null
  }
],
v5 = [
  {
    "kind": "InlineDataFragmentSpread",
    "name": "App_BenchmarkMetrics_Fragment",
    "selections": (v4/*: any*/)
  }
],
v6 = [
  {
    "kind": "Literal",
    "name": "limit",
    "value": 50
  },
  {
    "kind": "Literal",
    "name": "order_by",
    "value": [
      {
        "run_at": "desc"
      }
    ]
  },
  {
    "fields": [
      {
        "items": [
          {
            "kind": "Literal",
            "name": "_and.0",
            "value": {
              "pull_number": {
                "_is_null": true
              }
            }
          },
          (v2/*: any*/)
        ],
        "kind": "ListValue",
        "name": "_and"
      }
    ],
    "kind": "ObjectValue",
    "name": "where"
  }
];
return {
  "fragment": {
    "argumentDefinitions": [
      (v0/*: any*/),
      (v1/*: any*/)
    ],
    "kind": "Fragment",
    "metadata": null,
    "name": "App_BenchmarkView_Query",
    "selections": [
      {
        "alias": null,
        "args": (v3/*: any*/),
        "concreteType": "benchmarks",
        "kind": "LinkedField",
        "name": "benchmarks",
        "plural": true,
        "selections": (v5/*: any*/),
        "storageKey": null
      },
      {
        "alias": "comparisonBenchmarks",
        "args": (v6/*: any*/),
        "concreteType": "benchmarks",
        "kind": "LinkedField",
        "name": "benchmarks",
        "plural": true,
        "selections": (v5/*: any*/),
        "storageKey": null
      }
    ],
    "type": "query_root",
    "abstractKey": null
  },
  "kind": "Request",
  "operation": {
    "argumentDefinitions": [
      (v1/*: any*/),
      (v0/*: any*/)
    ],
    "kind": "Operation",
    "name": "App_BenchmarkView_Query",
    "selections": [
      {
        "alias": null,
        "args": (v3/*: any*/),
        "concreteType": "benchmarks",
        "kind": "LinkedField",
        "name": "benchmarks",
        "plural": true,
        "selections": (v4/*: any*/),
        "storageKey": null
      },
      {
        "alias": "comparisonBenchmarks",
        "args": (v6/*: any*/),
        "concreteType": "benchmarks",
        "kind": "LinkedField",
        "name": "benchmarks",
        "plural": true,
        "selections": (v4/*: any*/),
        "storageKey": null
      }
    ]
  },
  "params": {
    "cacheID": "0b7f97851be8d8a01d1e1b6eefa9d690",
    "id": null,
    "metadata": {},
    "name": "App_BenchmarkView_Query",
    "operationKind": "query",
    "text": "query App_BenchmarkView_Query(\n  $repoId: String!\n  $pullNumber: Int!\n) {\n  benchmarks(where: {_and: [{pull_number: {_eq: $pullNumber}}, {repo_id: {_eq: $repoId}}]}) {\n    ...App_BenchmarkMetrics_Fragment\n  }\n  comparisonBenchmarks: benchmarks(where: {_and: [{pull_number: {_is_null: true}}, {repo_id: {_eq: $repoId}}]}, limit: 50, order_by: [{run_at: desc}]) {\n    ...App_BenchmarkMetrics_Fragment\n  }\n}\n\nfragment App_BenchmarkMetrics_Fragment on benchmarks {\n  run_at\n  commit\n  test_name\n  metrics\n}\n"
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
