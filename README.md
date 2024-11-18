👋

# Tilt/Shift Config

Standard Javascript configuration for Tilt/Shift projects.

- [Prettier](https://prettier.io/)
- [Eslint](https://eslint.org/)

## Installation

```bash
yarn add --dev @tiltshift/config
```

## Usage

In your `package.json`

```json
{
  "prettier": "@tiltshift/config/prettier"
}
```

Add a file `eslint.config.mjs` to your proj ect with the following contents:

```
import tiltShiftConfig from '@tiltshift/config/eslint'

export default tiltShiftConfig
```