local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

-- Define the C++ snippet template
ls.add_snippets("cpp", {
    s("cpp_template", {
        t({
            "// MOHIT-IITP template",
            "#include <bits/stdc++.h>",
            "using namespace std;",
            "",
            "#define ll long long",
            "#define pb push_back",
            "#define MOD 1000000007",
            "",
            "void solve() {",
            "    ",
        }),
        i(1, "// your code here"), -- first cursor position
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
})
