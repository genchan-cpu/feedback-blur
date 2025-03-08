import * as THREE from "three";
import { OrbitControls } from "three/examples/jsm/controls/OrbitControls.js";
import vertex from "./shaders/vertex.glsl";
import blurFragment from "./shaders/blur.glsl";
import feedbackFragment from "./shaders/fragment.glsl";

const Config = {
  width: 100,
  height: 100,
  halfWidth: 50,
  halfHeight: 50,
  sceneWidth: 2,
  sceneHeight: 2,
  dpr: 1,
  aspectRatio: 1.0,
};

class Sketch {
  constructor(rendererEl) {
    this.rendererEl = rendererEl;
    this.time = 0;
    this.animationFrameId = null;
    this.isResumed = true;
    this.lastFrameTime = null;

    this.canvas = document.createElement("canvas");
    this.rendererEl.appendChild(this.canvas);

    this.camera = new THREE.OrthographicCamera(-1, 1, 1, -1, 0, 1);
    this.scene = new THREE.Scene();

    const rtParams = {
      minFilter: THREE.LinearFilter,
      magFilter: THREE.LinearFilter,
      format: THREE.RGBAFormat,
      type: THREE.FloatType,
    };

    this.currentRenderTarget = new THREE.WebGLRenderTarget(
      2048,
      2048,
      rtParams
    );
    this.prevRenderTarget = new THREE.WebGLRenderTarget(2048, 2048, rtParams);

    this.horizontalBlurTarget = new THREE.WebGLRenderTarget(
      2048,
      2048,
      rtParams
    );
    this.verticalBlurTarget = new THREE.WebGLRenderTarget(2048, 2048, rtParams);

    this.renderer = new THREE.WebGLRenderer({
      canvas: this.canvas,
      antialias: true,
      alpha: true,
    });
    this.renderer.setPixelRatio(window.devicePixelRatio);

    this.quad = new THREE.PlaneGeometry(2, 2);

    this.horizontalBlurMaterial = new THREE.ShaderMaterial({
      uniforms: {
        tDiffuse: { value: null },
        resolution: { value: new THREE.Vector2() },
        direction: { value: new THREE.Vector2(1.0, 0.0) },
        blur: { value: 1.0 },
      },
      vertexShader: vertex,
      fragmentShader: blurFragment,
    });

    this.verticalBlurMaterial = new THREE.ShaderMaterial({
      uniforms: {
        tDiffuse: { value: null },
        resolution: { value: new THREE.Vector2() },
        direction: { value: new THREE.Vector2(0.0, 1.0) },
        blur: { value: 1.0 },
      },
      vertexShader: vertex,
      fragmentShader: blurFragment,
    });

    this.feedbackMaterial = new THREE.ShaderMaterial({
      uniforms: {
        tPrevious: { value: null },
        tText: { value: null },
        time: { value: 0.0 },
        resolution: { value: new THREE.Vector2() },
      },
      vertexShader: vertex,
      fragmentShader: feedbackFragment,
    });

    this.mesh = new THREE.Mesh(this.quad, this.feedbackMaterial);
    this.scene.add(this.mesh);

    this.renderFrame = this.renderFrame.bind(this);
    this.handleVisibilityChange = this.handleVisibilityChange.bind(this);
    this.handleResize = this.handleResize.bind(this);

    this.handleResize();
    this.setupEventListeners();
    this.startRenderLoop();
  }

  initializeOrbitControls() {
    const controls = new OrbitControls(this.camera, this.rendererEl);
    controls.enableDamping = true;
    controls.update();
    return controls;
  }

  createTextTexture(width, height) {
    const canvas = document.createElement("canvas");
    const ctx = canvas.getContext("2d");

    canvas.width = 2048;
    canvas.height = 2048;

    if (ctx) {
      ctx.imageSmoothingEnabled = true;
      ctx.imageSmoothingQuality = "high";

      ctx.fillStyle = "rgba(0, 0, 0, 0)";
      ctx.fillRect(0, 0, canvas.width, canvas.height);

      const aspectRatio = width / height;
      const fontSize = (aspectRatio >= 1 ? 300 : 150) * 2;

      ctx.fillStyle = "WHITE";
      ctx.font = `bold ${fontSize}px Arial`;
      ctx.textAlign = "center";
      ctx.textBaseline = "middle";

      ctx.fillText("OGMA", canvas.width / 2, canvas.height / 2);
    }

    const texture = new THREE.CanvasTexture(canvas);
    texture.minFilter = THREE.LinearFilter;
    texture.magFilter = THREE.LinearFilter;
    texture.anisotropy = this.renderer.capabilities.getMaxAnisotropy();

    texture.needsUpdate = true;
    return texture;
  }

  handleResize() {
    const width = this.rendererEl.clientWidth;
    const height = this.rendererEl.clientHeight;
    const aspectRatio = width / height;

    this.currentRenderTarget.setSize(width, height);
    this.prevRenderTarget.setSize(width, height);
    this.horizontalBlurTarget.setSize(width, height);
    this.verticalBlurTarget.setSize(width, height);
    this.renderer.setSize(width, height);

    if (aspectRatio > 1) {
      this.camera.left = -aspectRatio;
      this.camera.right = aspectRatio;
      this.camera.top = 1;
      this.camera.bottom = -1;
    } else {
      this.camera.left = -1;
      this.camera.right = 1;
      this.camera.top = 1 / aspectRatio;
      this.camera.bottom = -1 / aspectRatio;
    }
    this.camera.updateProjectionMatrix();

    Config.width = width;
    Config.height = height;
    Config.aspectRatio = aspectRatio;

    this.horizontalBlurMaterial.uniforms.resolution.value.set(width, height);
    this.verticalBlurMaterial.uniforms.resolution.value.set(width, height);
    this.feedbackMaterial.uniforms.resolution.value.set(width, height);
    this.feedbackMaterial.uniforms.tText.value = this.createTextTexture(
      Config.width,
      Config.height
    );
  }

  handleVisibilityChange() {
    document.hidden ? this.stopRenderLoop() : this.startRenderLoop();
  }

  renderFrame(time) {
    this.animationFrameId = window.requestAnimationFrame(this.renderFrame);

    if (this.isResumed || !this.lastFrameTime) {
      this.lastFrameTime = window.performance.now();
      this.isResumed = false;
      return;
    }

    this.time += 0.01;

    this.mesh.material = this.horizontalBlurMaterial;
    this.horizontalBlurMaterial.uniforms.tDiffuse.value =
      this.prevRenderTarget.texture;
    this.renderer.setRenderTarget(this.horizontalBlurTarget);
    this.renderer.render(this.scene, this.camera);

    this.mesh.material = this.verticalBlurMaterial;
    this.verticalBlurMaterial.uniforms.tDiffuse.value =
      this.horizontalBlurTarget.texture;
    this.renderer.setRenderTarget(this.verticalBlurTarget);
    this.renderer.render(this.scene, this.camera);

    this.mesh.material = this.feedbackMaterial;
    this.feedbackMaterial.uniforms.tPrevious.value =
      this.verticalBlurTarget.texture;
    this.feedbackMaterial.uniforms.time.value = this.time;
    this.renderer.setRenderTarget(this.currentRenderTarget);
    this.renderer.clear();
    this.renderer.render(this.scene, this.camera);

    this.renderer.setRenderTarget(null);
    this.renderer.clear();
    this.renderer.render(this.scene, this.camera);

    const temp = this.currentRenderTarget;
    this.currentRenderTarget = this.prevRenderTarget;
    this.prevRenderTarget = temp;
  }

  setupEventListeners() {
    window.addEventListener("resize", this.handleResize);
    window.addEventListener("visibilitychange", this.handleVisibilityChange);
  }

  removeEventListeners() {
    window.removeEventListener("resize", this.handleResize);
    window.removeEventListener("visibilitychange", this.handleVisibilityChange);
  }

  startRenderLoop() {
    this.isResumed = true;
    if (!this.animationFrameId) {
      this.animationFrameId = window.requestAnimationFrame(this.renderFrame);
    }
  }

  stopRenderLoop() {
    if (this.animationFrameId) {
      window.cancelAnimationFrame(this.animationFrameId);
      this.animationFrameId = null;
    }
  }

  destroy() {
    if (this.canvas.parentNode) {
      this.canvas.parentNode.removeChild(this.canvas);
    }

    this.stopRenderLoop();
    this.removeEventListeners();

    this.currentRenderTarget.dispose();
    this.prevRenderTarget.dispose();
    this.quad.dispose();
    this.feedbackMaterial.dispose();
  }
}

window.addEventListener("load", () => {
  new Sketch(document.getElementById("canvas-container"));

})
