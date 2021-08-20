export const notifyVue = ({t, m, i, v, h, c}, _this) => {
  _this.$notify({
    timeout: t || 2000,
    message: m || '',
    icon: i || "add_alert",
    horizontalAlign: h || 'center',
    verticalAlign: v || 'bottom',
    type: c
  })
}