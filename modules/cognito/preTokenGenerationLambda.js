// @ts-nocheck
exports.handler = async (event) => {
  event.response = {
    claimsOverrideDetails: {
      claimsToAddOrOverride: {
        apiUrl: process.env.API_URL,
        apiUrl: process.env.ACCESS_HANDLER_URL,
      },
    },
  };
  return event;
};
