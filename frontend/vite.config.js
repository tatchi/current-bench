import { defineConfig } from "vite";
import reactRefresh from "@vitejs/plugin-react-refresh";

// https://vitejs.dev/config/
export default ({ mode }) => {
  if (mode === "development") {
    return defineConfig({
      define: {
        global: {},
      },
      plugins: [reactRefresh()],
      server: {
        port: 8082,
      },
    });
  }
  return {};
};
