const buildConfig = require('./docusaurus.config');

module.exports = {
  ...buildConfig,
  themeConfig: {
    ...buildConfig.themeConfig,
    algolia: {
      appId:'73S9SS6EV4',
      apiKey: '9c4aed39bcccd5054cea70ae1035e839',
      indexName: 'arcus-azure',
      // Set `contextualSearch` to `true` when having multiple versions!!!
      contextualSearch: true,
      searchParameters: {
        facetFilters: ["tags:scripting"]
      },
    },
  }
}