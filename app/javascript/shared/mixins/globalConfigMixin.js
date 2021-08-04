export default {
  methods: {
    useInstallationName(str = '', installationName) {
      return str.replace(/Abrand/g, globalConfig.installationName);
    },
  },
};
