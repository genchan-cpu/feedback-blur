import { defineConfig } from "vite";
import glsl from "vite-plugin-glsl";

export default defineConfig({
  plugins: [glsl()],
  resolve: {
    extensions: [".js", ".glsl", ".vs", ".fs"],
  },
});
