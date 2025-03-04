# GeoFyle Backend Developer Guidelines

## Commands
- Run tests: `npm test`
- Run unit tests: `npm run test:unit` 
- Run integration tests: `npm run test:integration`
- Run single test: `npx jest tests/unit/getNearbyFiles.test.js`
- Lint code: `npm run lint`
- Local development: `npm run local`
- Deploy to dev: `npm run deploy`
- Deploy to prod: `npm run deploy:prod`
- Deploy with custom domain: `npm run deploy:domain YOUR_HOSTED_ZONE_ID`
- Deploy to prod with custom domain: `npm run deploy:prod:domain YOUR_HOSTED_ZONE_ID`

## Code Style
- **Formatting**: 2 space indentation, Unix line endings, single quotes, required semicolons
- **Imports**: Use CommonJS `require()` syntax
- **Naming**: camelCase for variables/functions, descriptive names
- **Exports**: Use `module.exports` or `exports.handler` for Lambda functions
- **Types**: Use JSDoc comments for function documentation and parameter types
- **Error Handling**: Try/catch blocks in handlers, use `error()` utility for responses
- **Logging**: Use `console.error()` for errors
- **Models**: Follow schema patterns in `models/` directory