import types from '../../../mutation-types'
import ApiClient from '../../../../api/ApiClient.js'

const apiVersion = 'v3'
const resource = {
  fields: 'admin/fields',
  fieldGroup: 'admin/field_groups'
}

const actions = {
  /////////////////////// with Api ////////////////////////////////////////////////////
  ////////////////////////////// group //////////////////////////////////////////////////////////
  gSearch: (context, catename) => {
    return new Promise((resolve, reject) => {
      new ApiClient(`${resource.fieldGroup}?klass_name=${context.state.selectCatename ? context.state.selectCatename : catename}`, {apiVersion}).get()
        .then(res => {
          if (res.data.msg) context.commit(`global/${types.SET_ERROR}`, res.data.msg, {root: true})
          else if (res.data.data){
            if (!context.state.selectCatename) context.commit(types.admin.fields.selectCatename, catename)
            context.commit(types.admin.fields.setCategories, {catename, data: JSON.parse(res.data.data)});
          }
          resolve()
        })
        .catch(err => {
          context.commit(`global/${types.SET_ERROR}`, err, {root: true});
          reject(err)
        })
    })
  },
  gCreate: (context, formData) => {
    return new Promise((resolve, reject) => {
      new ApiClient(resource.fieldGroup, {apiVersion}).create(formData)
        .then(res => {
          if (res.data.msg) context.commit(`global/${types.SET_ERROR}`, res.data.msg, {root: true})
          resolve()
        })
        .catch(err => {
          context.commit(`global/${types.SET_ERROR}`, err, {root: true});
          reject(err)
        })
    })
  },
  gUpdate: (context, {id, formData}) => {
    return new Promise((resolve, reject) => {
      new ApiClient(resource.fieldGroup, {apiVersion}).update(id, formData)
        .then(res => {
          if (res.data.msg) context.commit(`global/${types.SET_ERROR}`, res.data.msg, {root: true})
          resolve()
        })
        .catch(err => {
          context.commit(`global/${types.SET_ERROR}`, err, {root: true});
          reject(err)
        })
    })
  },
  gDelete: (context, id) => {
    return new Promise((resolve, reject) => {
      new ApiClient(resource.fieldGroup, {apiVersion}).delete(id)
        .then(res => {
          if (res.data.msg) context.commit(`global/${types.SET_ERROR}`, res.data.msg, {root: true})
          resolve()
        })
        .catch(err => {
          context.commit(`global/${types.SET_ERROR}`, err, {root: true});
          reject(err)
        })
    })
  },
  //////////////////////////////////// field ///////////////////////////////////////////////////////////
  fCreate: (context, formData) => {
    return new Promise((resolve, reject) => {
      new ApiClient(resource.fields, {apiVersion}).create(formData)
        .then(res => {
          if (res.data.msg) context.commit(`global/${types.SET_ERROR}`, res.data.msg, {root: true})
          resolve()
        })
        .catch(err => {
          context.commit(`global/${types.SET_ERROR}`, err, {root: true});
          reject(err)
        })
    })
  },
  fUpdate: (context, {id, formData}) => {
    return new Promise((resolve, reject) => {
      new ApiClient(resource.fields, {apiVersion}).update(id, formData)
        .then(res => {
          if (res.data.msg) context.commit(`global/${types.SET_ERROR}`, res.data.msg, {root: true})
          resolve()
        })
        .catch(err => {
          context.commit(`global/${types.SET_ERROR}`, err, {root: true});
          reject(err)
        })
    })
  },
  fDelete: (context, id) => {
    return new Promise((resolve, reject) => {
      new ApiClient(resource.fields, {apiVersion}).delete(id)
        .then(res => {
          if (res.data.msg) context.commit(`global/${types.SET_ERROR}`, res.data.msg, {root: true})
          resolve()
        })
        .catch(err => {
          context.commit(`global/${types.SET_ERROR}`, err, {root: true});
          reject(err)
        })
    })
  },
  //////////////////////////////////////////////////////////////
  /////////////////// without Api //////////////////
  selectCatename: async (context, catename) => {
    context.commit(types.admin.fields.selectCatename, catename)
  },
  setCEGroupID: async (context, id) => {
    context.commit(types.admin.fields.setCEGroupID, id)
  },
  setCEFieldData: async (context, data) => {
    context.commit(types.admin.fields.setCEFieldData, data)
  }
  //////////////////////////////////////////////////////////////////////
};

export default actions;
