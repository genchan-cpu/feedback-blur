uniform sampler2D tPrevious;
uniform float time;
uniform vec2 resolution;
uniform float distortAmount;
uniform float feedbackAmount;
uniform float sharpness;
uniform sampler2D tText;
uniform float textAspectRatio;

varying vec2 vUv;

// Simplex 3D Noise
vec4 permute(vec4 x) { return mod(((x * 34.0) + 1.0) * x, 289.0); }
vec4 taylorInvSqrt(vec4 r) { return 1.79284291400159 - 0.85373472095314 * r; }

float snoise(vec3 v) {
  const vec2 C = vec2(1.0 / 6.0, 1.0 / 3.0);
  const vec4 D = vec4(0.0, 0.5, 1.0, 2.0);
  
  // First corner
  vec3 i = floor(v + dot(v, C.yyy));
  vec3 x0 = v - i + dot(i, C.xxx);
  
  // Other corners
  vec3 g = step(x0.yzx, x0.xyz);
  vec3 l = 1.0 - g;
  vec3 i1 = min(g.xyz, l.zxy);
  vec3 i2 = max(g.xyz, l.zxy);
  
  vec3 x1 = x0 - i1 + C.xxx;
  vec3 x2 = x0 - i2 + C.yyy;
  vec3 x3 = x0 - D.yyy;
  
  // Permutations
  i = mod(i, 289.0);
  vec4 p = permute(permute(permute(
        i.z + vec4(0.0, i1.z, i2.z, 1.0))
        + i.y + vec4(0.0, i1.y, i2.y, 1.0))
        + i.x + vec4(0.0, i1.x, i2.x, 1.0));
        
        // Gradients
        float n_ = 0.142857142857;
        vec3 ns = n_ * D.wyz - D.xzx;
        
        vec4 j = p - 49.0 * floor(p * ns.z * ns.z);
        
        vec4 x_ = floor(j * ns.z);
        vec4 y_ = floor(j - 7.0 * x_);
        
        vec4 x = x_ * ns.x + ns.yyyy;
        vec4 y = y_ * ns.x + ns.yyyy;
        vec4 h = 1.0 - abs(x) - abs(y);
        
        vec4 b0 = vec4(x.xy, y.xy);
        vec4 b1 = vec4(x.zw, y.zw);
        
        vec4 s0 = floor(b0) * 2.0 + 1.0;
        vec4 s1 = floor(b1) * 2.0 + 1.0;
        vec4 sh = -step(h, vec4(0.0));
        
        vec4 a0 = b0.xzyw + s0.xzyw * sh.xxyy;
        vec4 a1 = b1.xzyw + s1.xzyw * sh.zzww;
        
        vec3 p0 = vec3(a0.xy, h.x);
        vec3 p1 = vec3(a0.zw, h.y);
        vec3 p2 = vec3(a1.xy, h.z);
        vec3 p3 = vec3(a1.zw, h.w);
        
        // Normalise gradients
        vec4 norm = taylorInvSqrt(vec4(dot(p0, p0), dot(p1, p1), dot(p2, p2), dot(p3, p3)));
        p0 *= norm.x;
        p1 *= norm.y;
        p2 *= norm.z;
        p3 *= norm.w;
        
        // Mix final noise value
        vec4 m = max(0.6 - vec4(dot(x0, x0), dot(x1, x1), dot(x2, x2), dot(x3, x3)), 0.0);
        m = m * m;
        return 42.0 * dot(m * m, vec4(dot(p0, x0), dot(p1, x1), dot(p2, x2), dot(p3, x3)));
      }
      
      float fbm(vec3 p) {
        float value = 0.0;
        float amplitude = 1.0;
        float frequency = 1.0;
        
        for(int i = 0; i < 4; i ++ ) {
          // value += amplitude * abs(snoise(p) * frequency);
          value += amplitude * (snoise(p) * frequency);
          amplitude *= 0.01;
          frequency *= 0.01;
        }
        
        return value;
      }
      
      vec4 unsharp(vec2 uv, sampler2D img, vec2 texelSize, float strength) {
        vec4 color = vec4(0.0);
        float center = -220.0 - strength;
        
        color += 1.0 * texture(img, uv + vec2(-2.0, - 2.0) * texelSize);
        color += 4.0 * texture(img, uv + vec2(-1.0, - 2.0) * texelSize);
        color += 6.0 * texture(img, uv + vec2(0.0, - 2.0) * texelSize);
        color += 4.0 * texture(img, uv + vec2(1.0, - 2.0) * texelSize);
        color += 1.0 * texture(img, uv + vec2(2.0, - 2.0) * texelSize);
        color += 4.0 * texture(img, uv + vec2(-2.0, - 1.0) * texelSize);
        color += 16.0 * texture(img, uv + vec2(-1.0, - 1.0) * texelSize);
        color += 24.0 * texture(img, uv + vec2(0.0, - 1.0) * texelSize);
        color += 16.0 * texture(img, uv + vec2(1.0, - 1.0) * texelSize);
        color += 4.0 * texture(img, uv + vec2(2.0, - 1.0) * texelSize);
        color += 6.0 * texture(img, uv + vec2(-2.0, 0.0) * texelSize);
        color += 24.0 * texture(img, uv + vec2(-1.0, 0.0) * texelSize);
        color += center * texture(img, uv + vec2(0.0, 0.0) * texelSize);
        color += 24.0 * texture(img, uv + vec2(1.0, 0.0) * texelSize);
        color += 6.0 * texture(img, uv + vec2(2.0, 0.0) * texelSize);
        color += 4.0 * texture(img, uv + vec2(-2.0, 1.0) * texelSize);
        color += 16.0 * texture(img, uv + vec2(-1.0, 1.0) * texelSize);
        color += 24.0 * texture(img, uv + vec2(0.0, 1.0) * texelSize);
        color += 16.0 * texture(img, uv + vec2(1.0, 1.0) * texelSize);
        color += 4.0 * texture(img, uv + vec2(2.0, 1.0) * texelSize);
        color += 1.0 * texture(img, uv + vec2(-2.0, 2.0) * texelSize);
        color += 4.0 * texture(img, uv + vec2(-1.0, 2.0) * texelSize);
        color += 6.0 * texture(img, uv + vec2(0.0, 2.0) * texelSize);
        color += 4.0 * texture(img, uv + vec2(1.0, 2.0) * texelSize);
        color += 1.0 * texture(img, uv + vec2(2.0, 2.0) * texelSize);
        
        return color / (-strength);
      }
      
      // 回転を含むディスプレイスメント効果用の関数
      vec2 displaceUV(vec2 uv, float amount) {
        // 画面中心からの距離と方向を計算
        vec2 center = vec2(0.5, 0.5);
        vec2 dir = uv - center;
        float dist = length(dir);
        
        // 回転角度を計算（時間に応じて変化）
        float angle = time * 0.3;
        
        // ノイズで回転角度を変化させる
        float noiseVal = snoise(vec3(uv * 2.0, time * 0.2)) * 0.5;
        angle += noiseVal * 0.5;
        
        // 回転行列
        float s = sin(angle);
        float c = cos(angle);
        mat2 rotationMatrix = mat2(c, - s, s, c);
        
        // 中心からの方向ベクトルを回転
        vec2 rotatedDir = rotationMatrix * dir;
        
        // 時間によって変化する波状のディスプレイスメント
        float waveFactor = sin(dist * 10.0 - time * 0.1) * 0.5 + 0.5;
        
        // 回転した方向に沿ってUVを変形
        vec2 offset = normalize(rotatedDir) * (waveFactor * amount + noiseVal * amount * 0.5);
        
        // 中心に近いほど効果を小さく
        offset *= smoothstep(0.0, 0.8, dist);
        
        return uv + offset;
      }
      
      void main() {
        vec2 uv = vUv;
        
        // ディスプレイスメントの強さ（必要に応じて調整）
        float displacementAmount = 0.02;
        
        // ディスプレイスメントを適用したUV座標を計算
        vec2 displacedUV = displaceUV(uv, displacementAmount);
        
        // アスペクト比を考慮してテキストのUV座標を調整
        vec2 textUv = displacedUV;
        float aspect = resolution.x / resolution.y;
        
        // 画面の中心を基準に座標を調整
        textUv.x = (textUv.x - 0.5) * aspect + 0.5;
        
        vec2 texelSize = vec2(1.0 / resolution * 2.0);
        
        vec4 textColor = texture2D(tText, textUv);
        vec4 previous = texture2D(tPrevious, displacedUV);
        
        float n = fbm(vec3(displacedUV, time * 1.0));
        vec4 initialColor = vec4(n, n, n, 1.0);
        
        initialColor = mix(initialColor, textColor, textColor.a * 0.0);
        
        gl_FragColor += unsharp(displacedUV, tPrevious, texelSize * 5.0, 64.0);
        gl_FragColor += initialColor;
        gl_FragColor = clamp(gl_FragColor, 0.0, 1.0);
      }