
/* @generated */

%bs.raw
"/* @generated */";

module Types = {
  [@ocaml.warning "-30"];
  type fragment_benchmarks = {
    pull_number: option(int),
    branch: option(string),
  };

  type fragment = {benchmarks: array(fragment_benchmarks)};
};

module Internal = {
  type fragmentRaw;
  let fragmentConverter: Js.Dict.t(Js.Dict.t(Js.Dict.t(string))) = [%raw
    {json| {"__root":{"benchmarks_branch":{"n":""},"benchmarks_pull_number":{"n":""}}} |json}
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
  ReasonRelay.fragmentRefs([> | `Sidebar2_PullsMenu_query]) => fragmentRef =
  "%identity";

module Utils = {};

type relayOperationNode;

type operationType = ReasonRelay.fragmentNode(relayOperationNode);



let node: operationType = [%raw {json| {
  "argumentDefinitions": [
    {
      "defaultValue": null,
      "kind": "LocalArgument",
      "name": "repoId"
    }
  ],
  "kind": "Fragment",
  "metadata": null,
  "name": "Sidebar2_PullsMenu_query",
  "selections": [
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
  ],
  "type": "query_root",
  "abstractKey": null
} |json}];


