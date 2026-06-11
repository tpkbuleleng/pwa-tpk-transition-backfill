// src/providers/BackendProvider.js

export class BackendProvider {
  constructor(config = {}) {
    this.config = config;
  }

  getProviderName() {
    throw new Error("getProviderName() belum diimplementasikan.");
  }

  healthCheck() {
    throw new Error("healthCheck() belum diimplementasikan.");
  }

  login(_payload) {
    throw new Error("login() belum diimplementasikan.");
  }

  logout() {
    throw new Error("logout() belum diimplementasikan.");
  }

  getMyProfileLite(_payload) {
    throw new Error("getMyProfileLite() belum diimplementasikan.");
  }

  getMasterRefs(_payload) {
    throw new Error("getMasterRefs() belum diimplementasikan.");
  }

  submitRegistrasi(_payload) {
    throw new Error("submitRegistrasi() belum diimplementasikan.");
  }

  submitPendampingan(_payload) {
    throw new Error("submitPendampingan() belum diimplementasikan.");
  }

  submitBatch(_payload) {
    throw new Error("submitBatch() belum diimplementasikan.");
  }

  getSubmitStatus(_payload) {
    throw new Error("getSubmitStatus() belum diimplementasikan.");
  }
}
