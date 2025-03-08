# Blur Feedback Effect

This project is a React + Three.js implementation of a pixel distortion effect, inspired by [Codrops' Pixel Distortion Effect tutorial](https://tympanus.net/codrops/2022/01/12/pixel-distortion-effect-with-three-js/). The effect creates an interactive distortion on images based on mouse movement.

![Image](https://github.com/user-attachments/assets/8561b443-37c2-4bdb-b1e5-644cc4e921f3)

## Images

Photos used in this project are from [Unsplash](https://unsplash.com/), a free and open source image library.

## Overview

This implementation uses modern React and Three.js tooling, specifically:

- React Three Fiber (@react-three/fiber)
- React Three Drei (@react-three/drei)
- Leva for interactive controls
- Vite as the build tool

## Features

- Real-time pixel distortion based on mouse movement
- Configurable parameters using Leva controls:
  - Grid size
  - Mouse influence factor
  - Distortion strength
  - Relaxation speed
- Orthographic camera view
- Shader-based rendering

## Technical Details

The distortion effect is achieved through:

- Custom shader materials (vertex and fragment shaders)
- Data texture for storing distortion values
- Mouse movement velocity calculations
- Dynamic texture updates

## Installation

## Reference
[Youtube]( https://www.youtube.com/watch?v=CzmRMKQBMSw)32


```bash
# Clone the repository
git clone [your-repo-url]

# Install dependencies
npm install or pnpm install

# Run development server
npm run dev or pnpm run dev
```
