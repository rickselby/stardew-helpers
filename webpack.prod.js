const {merge} = require('webpack-merge');
const common = require('./webpack.config.js');

module.exports = merge(common, {
    mode: 'production',
    output: {
        filename: '[name]-[contenthash].js',
    },
});
