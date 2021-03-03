
/* @generated */

%bs.raw
"/* @generated */";

module Types = {
  [@ocaml.warning "-30"];
  type fragment_benchmarks = {repo_id: string};

  type fragment = {benchmarks: array(fragment_benchmarks)};
};

module Internal = {
  type fragmentRaw;
  let fragmentConverter: Js.Dict.t(Js.Dict.t(Js.Dict.t(string))) = [%raw
    {json| {} |json}
  ];
  let fragmentConverterMap = ();
  let convertFragment = v =>
    v->ReasonRelay.convertObj(
      fragmentConverter,
      fragmentConverterMap,
      Js.undefined,
    );
};

type t;
type fragmentRef;
external getFragmentRef:
  ReasonRelay.fragmentRefs([> | `Sidebar2_SelectRepo_query]) => fragmentRef =
  "%identity";

module Utils = {};

type relayOperationNode;

type operationType = ReasonRelay.fragmentNode(relayOperationNode);



let node: operationType = [%raw {json| {
  "argumentDefinitions": [],
  "kind": "Fragment",
  "metadata": null,
  "name": "Sidebar2_SelectRepo_query",
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
  ],
  "type": "query_root",
  "abstractKey": null
} |json}];


