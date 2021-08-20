<template>
  <div>
    <div class="d-flex justify-content-between align-baseline"
      @mouseover="btToggle = true" @mouseleave="btToggle = false"
    >
      <div class="d-flex ad-fields-field" >
        <h6 style="margin-bottom: 0; padding-top: 3px; color: black" v-html="field.label" />
        <strong style="padding: 0 3px;" v-html="checkAs(field.as)" />
        <small v-html="createTime(field.created_at)" />
      </div>
      <div class="md-group" :style="btToggle ? 'visibility: visible;' : 'visibility: hidden;'">
        <md-button class="md-raised md-dense" :class="openModal ? 'md-primary' : 'md-info'" style="padding: 0;" 
        @click="editField">
          {{openModal ? 'Cancel' : 'Edit'}}
        </md-button>
        <md-button class="md-icon-button md-danger md-raised md-dense" style="padding: 0;" @click="deleteField">
          <i class="icon ion-android-delete"></i>
        </md-button>
      </div>
    </div>
    <EditField 
    :openModal="openModal" 
    :gid="Number(gid)" 
    :field="JSON.parse(JSON.stringify(field))" 
    @closeCEFieldModal="editField"/>
  </div>
</template>

<script>
  import {ADMIN_FIELD_AS} from '../../../../common/config.js'
  import EditField from './editField.vue'

  export default {
    name: 'ad-fields-field',
    props: {
      gid: {
        type: String,
        default: null
      },
      field: {
        type: Object,
        default: () => {
          return {fields: []}
        }
      },
      ceFieldData: {
        type: Object,
        default: () => {}
      }
    },
    components: {
      EditField,
    },
    data() {
      return {
        btToggle: false,
        openModal: false,
      };
    },
    beforeUpdate() {
      this.openModal = this.$props.ceFieldData[this.$props.gid] && this.$props.ceFieldData[this.$props.gid][this.$props.field.id] ? true : false
    },
    methods: {
      checkTime(gap, str) {
        let reStr = gap > 1 ? `${str}s` : str
        return gap > 0 ? `added about ${gap} ${reStr} ago` : null
      },
      checkAs(as) {
        let inx = Object.values(ADMIN_FIELD_AS).indexOf(as)
        return inx > -1 ? `( ${Object.keys(ADMIN_FIELD_AS)[inx]} )` : null
      },
      createTime(time) {
        let create = new Date(time)
        let now  = new Date()
        let str = this.checkTime(now.getFullYear() - create.getFullYear(), 'year')
        if (str) return str
        else {
          str = this.checkTime(now.getMonth() - create.getMonth(), 'month')
          if (str) return str
          else {
            str = this.checkTime(now.getDate() - create.getDate(), 'day')
            if (str) return str
            else {
              str = this.checkTime(now.getHours() - create.getHours(), 'hour')
              if (str) return str
              else {
                str = this.checkTime(now.getMinutes() - create.getMinutes(), 'min')
                return str ? str : `added about secs ago`
              }
            }
          }
        }
      },
      editField() {
        let data = {gid: this.$props.gid}
        this.$props.ceFieldData[this.$props.gid] && this.$props.ceFieldData[this.$props.gid][this.$props.field.id]
        ? Object.assign(data, {del: String(this.$props.field.id)}) 
        : Object.assign(data, {add: {[this.$props.field.id] : this.$props.field}})
        Promise.all([
          this.$store.dispatch('adFields/setCEFieldData', data)
        ]).then(() => {
            this.openModal = this.$props.ceFieldData[this.$props.gid] && this.$props.ceFieldData[this.$props.gid][this.$props.field.id] ? true : false
        })
      },
      deleteField() {

      },
    },
  };
</script>
<style lang="scss">
</style>
