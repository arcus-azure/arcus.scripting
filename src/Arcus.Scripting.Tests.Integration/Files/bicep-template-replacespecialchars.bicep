resource test 'Microsoft.ApiManagement/service/apis@2019-01-01' = {
  name: 'apimanagement/api'
  properties: {
    subscriptionRequired: true
    path: 'demo'
    value: '${ ./../Files/bicep-template-replacespecialchars-value.xml, ReplaceSpecialChars }$'
    format: 'swagger-json'
  }
  dependsOn: []
}
