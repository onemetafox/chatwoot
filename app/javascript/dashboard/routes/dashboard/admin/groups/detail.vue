<template>
  <div class="md-layout d-flex justify-content-between align-baseline pt-1 pb-1 ad-groups-detail"
    @mouseover="btToggle = true" @mouseleave="btToggle = false">
    <div class="d-flex">
      <div class="strip" style="background: #add8e6; width: auto;">
        <strong style="font-size: 15px;" v-html="group.name" />
      </div>
      <div v-for="(user, n) in group.users" :key="`user-${n}`" class="pl-2">
        <md-divider class="md-hr md-theme-demo-light" />
        <a href="#" style="color: saddlebrown; font-weight: 700;"  v-html="fullUserName(user)" />
      </div>
    </div>
    <div class="md-group" :style="btToggle ? 'visibility: visible;' : 'visibility: hidden;'">
      <md-button class="md-icon-button md-info md-raised md-dense" @click="showModal">
        <i class="icon ion-edit"></i>
      </md-button>
      <md-button class="md-icon-button md-danger md-raised md-dense" @click="deleteGroup">
        <i class="icon ion-android-delete"></i>
      </md-button>
    </div>
  </div>
</template>

<script>
import Swal from "sweetalert2";

export default {
  name: 'ad-groups-detail',
  props: {
    group: {
      type: Object,
      default: () => {}
    }
  },
  data() {
    return {
      btToggle: false
    };
  },
  methods: {
    fullUserName(user) {
      let tmp = ''
      if (user.first_name && user.last_name) tmp = `${user.first_name} ${user.last_name}`
      else {
        if (user.first_name) tmp = user.first_name
        if (user.last_name) tmp = user.last_name
      }
      if (!tmp) {
        if (user.username) tmp = user.username
        if (user.email) tmp = user.email
      }
      return tmp
    },
    showModal() {
      this.$store.dispatch('adGroups/get', this.$props.group.id).then(group => {
        if (group) {
          this.$store.dispatch('adGroups/get').then(() => {
            this.$store.dispatch('adGroups/editID', this.$props.group.id)
          })
        }
      })
      this.$store.dispatch('adGroups/editID', this.$props.group.id)
    },
    deleteGroup() {
      let tmp = JSON.stringify(this.$props.group.name)
      Swal.fire({
        title: 'Are you sure?',
        text: `You will not be able to recover "${tmp}" group!`,
        showCancelButton: true,
        confirmButtonText: 'Yes, delete it!',
        cancelButtonText: 'No, keep it'
      }).then((result) => {
        if (result.value) {
          this.$store.dispatch('adGroups/delete', this.$props.group.id).then(() => {
            Promise.all([
              this.$store.dispatch('adGroups/get'),
              this.$store.dispatch('adUsers/search')
            ]).then(() => {
              this.$store.dispatch('global/setMsg', `Deleted "${tmp}" group..`)
            })
          })
        }
      })
    },
  },
};
</script>

<style lang="scss">
.ad-groups-detail:hover {
  background: #efefef;;
}
.ad-groups-detail{
  .strip {
    height: 25px;
    width: auto;
    background: #dcdcdc;
    color: black;
    float: left;
    font-size: 11px;
    margin: 0px 6px 0px 0px;
    padding: 1px 4px 1px 3px;
    text-align: right;
    width: 75px;
    -moz-border-radius-topleft: 7px;
    -moz-border-radius-bottomleft: 7px;
    -webkit-border-top-left-radius: 7px;
    -webkit-border-bottom-left-radius: 7px;
  }
}
</style>
