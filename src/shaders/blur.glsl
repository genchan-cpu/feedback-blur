// ブラーシェーダー
uniform sampler2D tDiffuse;
uniform vec2 resolution;
uniform vec2 direction;
uniform float blur;
varying vec2 vUv;

vec4 blur3(vec2 uv, sampler2D tex, vec2 texelSize, vec2 direction) {
  vec4 color = vec4(0.0);
  texelSize *= direction;
  color += 0.3529411764705882 * texture(tex, uv + vec2(-1.3333333333333335) * texelSize);
  color += 0.29411764705882354 * texture(tex, uv + vec2(0.0) * texelSize);
  color += 0.3529411764705882 * texture(tex, uv + vec2(1.3333333333333335) * texelSize);
  return color;
}

vec4 blur7(vec2 uv, sampler2D tex, vec2 texelSize, vec2 direction) {
  vec4 color = vec4(0.0);
  texelSize *= direction;
  
  color += 0.010381362401148057 * texture2D(tex, uv + vec2(-5.1764705882352935) * texelSize);
  color += 0.09447039785044732 * texture2D(tex, uv + vec2(-3.294117647058824) * texelSize);
  color += 0.2969069646728344 * texture2D(tex, uv + vec2(-1.411764705882353) * texelSize);
  color += 0.1964825501511404 * texture2D(tex, uv + vec2(0.0) * texelSize);
  color += 0.2969069646728344 * texture2D(tex, uv + vec2(1.411764705882353) * texelSize);
  color += 0.09447039785044732 * texture2D(tex, uv + vec2(3.294117647058824) * texelSize);
  color += 0.010381362401148057 * texture2D(tex, uv + vec2(5.1764705882352935) * texelSize);
  
  return color;
}

vec4 blur11(vec2 uv, sampler2D tex, vec2 texelSize, vec2 direction) {
  vec4 color = vec4(0.0);
  texelSize *= direction;
  color += 0.0001370910915466891 * texture(tex, uv + vec2(-9.12) * texelSize);
  color += 0.0031668042147285184 * texture(tex, uv + vec2(-7.199999999999999) * texelSize);
  color += 0.028652038133258024 * texture(tex, uv + vec2(-5.279999999999999) * texelSize);
  color += 0.1217711620663466 * texture(tex, uv + vec2(-3.3600000000000003) * texelSize);
  color += 0.2656825354174835 * texture(tex, uv + vec2(-1.44) * texelSize);
  color += 0.16118073815327333 * texture(tex, uv + vec2(0.0) * texelSize);
  color += 0.2656825354174835 * texture(tex, uv + vec2(1.44) * texelSize);
  color += 0.1217711620663466 * texture(tex, uv + vec2(3.3600000000000003) * texelSize);
  color += 0.028652038133258024 * texture(tex, uv + vec2(5.279999999999999) * texelSize);
  color += 0.0031668042147285184 * texture(tex, uv + vec2(7.199999999999999) * texelSize);
  color += 0.0001370910915466891 * texture(tex, uv + vec2(9.12) * texelSize);
  return color;
}

void main() {
  vec2 texelSize = (1.0 / resolution) * blur;
  gl_FragColor = blur3(vUv, tDiffuse, texelSize, direction);
}