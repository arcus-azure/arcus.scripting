resource test 'Microsoft.ApiManagement/service/apis@2019-01-01' = {
  name: 'apimanagement/api'
  properties: {
    subscriptionRequired: true
    path: 'demo'
    value: '${ FileToInject='./../Files/bicep-template-object-value (windows).json', ReplaceSpecialChars, InjectAsBicepObject }$'
    format: 'swagger-json'
  }
  dependsOn: []
}
