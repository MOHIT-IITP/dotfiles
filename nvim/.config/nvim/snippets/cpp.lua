local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

return {
  s("mtemp", {
    t({
      "// MOHIT-IITP template",
      "#include <bits/stdc++.h>",
      "using namespace std;",
      "",
      "#define ll long long",
      "#define el endl",
      "#define pb push_back",
      "#define MOD 1000000007",
      "",
      "void solve() {",
      "    ",
    }),
    i(1, "// your code here"),
    t({
      "",
      "}",
      "",
      "int main() {",
      "    ios::sync_with_stdio(false);",
      "    cin.tie(nullptr);",
      "    int t; cin >> t;",
      "    while (t--) solve();",
      "    return 0;",
      "}",
    }),
  }),
}
