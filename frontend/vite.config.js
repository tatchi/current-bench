import { defineConfig } from "vite";
import reactRefresh from "@vitejs/plugin-react-refresh";

// https://vitejs.dev/config/
export default defineConfig({
  define: {
    global: {},
  },
  plugins: [reactRefresh()],
  server: {
    port: 8082,
  },
});
