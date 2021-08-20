import types from '../../../mutation-types'
import ApiClient from '../../../../api/ApiClient.js'

const apiVersion = 'v3'
const resource = 'admin/users'

const actions = {
  //////////////////////// with Api ////////////////////////
  search: (context, query) => {
    return new Promise((resolve, reject) => {
      let url = query ? `${resource}?query=${query}` : resource
      new ApiClient(url, {apiVersion}).get()
        .then(res => {
          if (res.msg) context.commit(`global/${types.SET_ERROR}`, res.msg, {root: true})
          else if (res.data) context.commit(types.admin.users.set, res.data);
          resolve()
        })
        .catch(err => {
          context.commit(`global/${types.SET_ERROR}`, err, {root: true});
          reject(err)
        })
    })
  },
  show: (context, id) => {
    return new Promise((resolve, reject) => {
      new ApiClient(resource, {apiVersion}).show(id)
        .then(res => {
          if (res.msg) context.commit(`global/${types.SET_ERROR}`, res.msg, {root: true})
          res.data ? resolve(res.data) : resolve()
        })
        .catch(err => {
          context.commit(`global/${types.SET_ERROR}`, err, {root: true});
          reject(err)
        })
    })
  },
  update: (context, {id, formData}) => {
    return new Promise((resolve, reject) => {
      id
      ? new ApiClient(resource, {apiVersion}).update(id, formData)
          .then(res => {
            if (res.msg) context.commit(`global/${types.SET_ERROR}`, res.msg, {root: true})
            resolve()
          })
          .catch(err => {
            context.commit(`global/${types.SET_ERROR}`, err, {root: true});
            reject(err)
          })
      : new ApiClient(resource, {apiVersion}).create(id, formData)
          .then(res => {
            if (res.msg) context.commit(`global/${types.SET_ERROR}`, res.msg, {root: true})
            resolve()
          })
          .catch(err => {
            context.commit(`global/${types.SET_ERROR}`, err, {root: true});
            reject(err)
          })
    })
  },
  delete: (context, id=null) => {
    return new Promise((resolve, reject) => {
      id
      ? new ApiClient(resource, {apiVersion}).delete(id)
        .then(res => {
          if (res.msg) context.commit(`global/${types.SET_ERROR}`, res.msg, {root: true})
          resolve()
        })
        .catch(err => {
          context.commit(`global/${types.SET_ERROR}`, err, {root: true});
          reject(err)
        })
      : resolve()
    })
  },
  sustoggle: (context, {id, suspend_at}) => {
    return new Promise((resolve, reject) => {
      let slug = suspend_at ? 'reactivate' : 'suspend'
      id
      ? new ApiClient(`${resource}/${id}/${slug}`).get()
          .then(res => {
            if (res.msg) context.commit(`global/${types.SET_ERROR}`, res.msg, {root: true})
            resolve()
          })
          .catch(err => {
            context.commit(`global/${types.SET_ERROR}`, err, {root: true});
            reject(err)
          })
      : resolve()
    })
  },
  ///////////////////////// without Api /////////////////////////////
  query: async (context, query) => {
    query
    ? context.commit(types.admin.users.query, query)
    : context.commit(types.admin.users.query, null)
  },
  editID: async (context, editID) => {
    context.commit(types.admin.users.editID, editID);
  }
};

export default actions;
