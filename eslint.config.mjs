import js from '@eslint/js'
import globals from 'globals'
import pluginVue from 'eslint-plugin-vue'
import skipFormatting from '@vue/eslint-config-prettier/skip-formatting'

export default [
  { ignores: ['dist/**'] },
  js.configs.recommended,
  ...pluginVue.configs['flat/essential'],
  skipFormatting,
  {
    files: ['src/**/*.{js,vue}'],
    languageOptions: { globals: globals.browser }
  },
  {
    files: ['postcss.config.js', 'tailwind.config.js'],
    languageOptions: { globals: globals.node, sourceType: 'commonjs' }
  }
]
