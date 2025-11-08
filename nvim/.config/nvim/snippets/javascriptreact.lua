local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

return {
  -- React Arrow Function Component (RAFC)
  s("rafc", {
    t("import React from 'react';"),
    t({ "", "", "const " }), i(1, "ComponentName"),
    t(" = () => {"),
    t({ "", "  return (" }),
    t({ "", "    <div>" }), i(2, "content"), t("</div>"),
    t({ "", "  );", "};", "", "", "export default " }), i(3, "ComponentName"), t(";"),
  }),

  -- React Arrow Function Component with export default (RAFCE)
  s("rafce", {
    t("import React from 'react';"),
    t({ "", "", "const " }), i(1, "ComponentName"),
    t(" = () => {"),
    t({ "", "  return (" }),
    t({ "", "    <>" }), i(2, "content"), t({"</>"}),
    t({ "", "  );", "};", "", "", "export default " }), i(3, "ComponentName"), t(";"),
  }),
}

