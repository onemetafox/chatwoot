<template>
  <div class="ad-fields-group">
    <div>
      <div>
        <div class="d-flex justify-content-between align-baseline"
          @mouseover="btToggle = true" @mouseleave="btToggle = false"
        >
          <h5 style="margin-bottom: 0; color: black; font-weight: 700" v-html="group.name" />
          <div class="md-group" :style="btToggle ? 'visibility: visible;' : 'visibility: hidden;'">
            <md-button class="md-icon-button md-info md-raised md-dense" style="padding: 0;" @click="editGroup">
              <i class="icon ion-edit"></i>
            </md-button>
            <md-button class="md-raised md-dense" :class="openModal ? 'md-primary' : 'md-success'" style="padding: 0;" @click="toggleCEField">
              {{openModal ? 'Cancel Field' : 'New Field'}}
            </md-button>
            <md-button class="md-icon-button md-danger md-raised md-dense" style="padding: 0;" @click="deleteGroup">
              <i class="icon ion-android-delete"></i>
            </md-button>
          </div>
        </div>
        <md-divider class="md-hr md-theme-demo-light"></md-divider>
      </div>
      <div v-for="(field, n) in group.fields" :key="`agff-${n}`">
        <Field :gid="group.id ? String(group.id) : null" :field="field" :ceFieldData="ceFieldData" />
        <md-divider class="md-hr md-theme-demo-light"></md-divider>
      </div>
    </div>
    <md-divider class="md-hr md-theme-demo-light"></md-divider>
    <EditField
      :openModal="openModal"
      :gid="Number(group.id)"
      :field="ceFieldData[group.id] && ceFieldData[group.id].new ? ceFieldData[group.id].new : {id: 'new'}"
      @closeCEFieldModal="toggleCEField" />
    <br/>
  </div>
</template>

<script>
  import Field from './field.vue'
  import EditField from './editField.vue'
  import Swal from "sweetalert2";

  export default {
    name: 'ad-fields-group',
    props: {
      group: {
        type: Object,
        default: () => {fields: []}
      },
      ceFieldData: {
        type: Object,
        default: () => {}
      },
      selectCatename: {
        type: String,
        default: 'Account'
      }
    },
    components:{
      Field,
      EditField
    },
    beforeUpdate() {
      this.openModal = this.$props.ceFieldData[this.$props.group.id]?.new ? true : false
    },
    data() {
      return {
        btToggle: false,
        openModal: false
      };
    },
    methods: {
      editGroup() {
        this.$store.dispatch('adFields/setCEGroupID', this.$props.group.id)
        .then(() => {
          this.$bvModal.show('ceGroupModal');
        })
      },
      deleteGroup() {
        let orglabel = JSON.stringify(this.$props.group.label)
        Swal.fire({
          title: 'Are you sure?',
          text: `Not be able to recover "${orglabel}" group!`,
          showCancelButton: true,
          confirmButtonText: 'Yes, delete it!',
          cancelButtonText: 'No, keep it'
        }).then((result) => {
          if (result.value) {
            this.$store.dispatch('adFields/gDelete', this.$props.group.id)
            .then(() => {
              Promise.all([
                this.$store.dispatch('adFields/gSearch', this.$props.selectCatename),
                this.$store.dispatch('adTgas/get')
              ]).then(() => {
                this.$store.dispatch('global/setMsg', `Deleted "${orglabel}" group!`)
              })
            })
          }
        })
      },
      toggleCEField() {
        let data = {gid: this.$props.group.id}
        this.$props.ceFieldData[this.$props.group.id]?.new
          ? Object.assign(data, {del: 'new'})
          : Object.assign(data, {add: {new: {id: 'new'}}})
        this.$store.dispatch('adFields/setCEFieldData', data)
        .then(() => {
          this.openModal = this.$props.ceFieldData[this.$props.group.id] && this.$props.ceFieldData[this.$props.group.id].new ? true : false
        })
      },
    },
  };
</script>
<style lang="scss">
</style>
