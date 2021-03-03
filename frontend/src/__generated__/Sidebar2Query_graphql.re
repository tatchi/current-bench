
/* @generated */

%bs.raw
"/* @generated */";

module Types = {
  [@ocaml.warning "-30"];

  type response = {
    fragmentRefs: ReasonRelay.fragmentRefs([ | `Sidebar2_SelectRepo_query]),
  };
  type rawResponse = response;
  type variables = unit;
};

module Internal = {
  type wrapResponseRaw;
  let wrapResponseConverter: Js.Dict.t(Js.Dict.t(Js.Dict.t(string))) = [%raw
    {json| {"__root":{"":{"f":""}}} |json}
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
    {json| {"__root":{"":{"f":""}}} |json}
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



let node: operationType = [%raw {json| {
  "fragment": {
    "argumentDefinitions": [],
    "kind": "Fragment",
    "metadata": null,
    "name": "Sidebar2Query",
    "selections": [
      {
        "args": null,
        "kind": "FragmentSpread",
        "name": "Sidebar2_SelectRepo_query"
      }
    ],
    "type": "query_root",
    "abstractKey": null
  },
  "kind": "Request",
  "operation": {
    "argumentDefinitions": [],
    "kind": "Operation",
    "name": "Sidebar2Query",
    "selections": [
      {
        "alias": null,
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
    ]
  },
  "params": {
    "cacheID": "41df8954b60133ea4f9c85dfb1f259f5",
    "id": null,
    "metadata": {},
    "name": "Sidebar2Query",
    "operationKind": "query",
    "text": "query Sidebar2Query {\n  ...Sidebar2_SelectRepo_query\n}\n\nfragment Sidebar2_SelectRepo_query on query_root {\n  benchmarks(distinct_on: [repo_id]) {\n    repo_id\n  }\n}\n"
  }
} |json}];

include ReasonRelay.MakeLoadQuery({
    type variables = Types.variables;
    type loadedQueryRef = queryRef;
    type response = Types.response;
    type node = relayOperationNode;
    let query = node;
    let convertVariables = Internal.convertVariables;
  });
