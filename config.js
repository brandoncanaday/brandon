module.exports = {
    PUBLIC_URL: process.env.APP_SECRET_PUBLIC_URL,
    REACT_APP_ENV: JSON.stringify({
        APP_TITLE: process.env.APP_SECRET_REACT_APP_ENV_APP_TITLE,
    }),
};
