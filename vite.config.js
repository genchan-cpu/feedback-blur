import { defineConfig } from "vite";
import glsl from "vite-plugin-glsl";

export default defineConfig({
  plugins: [glsl()],
  // その他の設定
  resolve: {
    extensions: [".js", ".glsl", ".vs", ".fs"],
  },
});
