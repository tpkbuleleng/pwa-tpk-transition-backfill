import { validateSelectiveExportPayload7G } from '../src/contracts/selectiveExportContract7G.js';
import { validateImportBatchFinalizationPayload7G } from '../src/contracts/importBatchFinalizationContract7G.js';

function assert(condition, message) {
  if (!condition) throw new Error(message);
}

const rowRange = validateSelectiveExportPayload7G({
  sheet_name: 'staging_sasaran',
  source_table: 'sasaran',
  export_scope: 'ROW_RANGE',
  start_row: 2,
  end_row: 5
});
assert(rowRange.ok, 'ROW_RANGE payload should be valid');

const missingKeys = validateSelectiveExportPayload7G({
  sheet_name: 'staging_sasaran',
  source_table: 'sasaran',
  export_scope: 'RECORD_KEYS'
});
assert(!missingKeys.ok, 'RECORD_KEYS without record_keys should be invalid');

const finalizeOk = validateImportBatchFinalizationPayload7G({
  import_batch_id: 'IMP_TEST_001',
  export_batch_id: 'EXP_TEST_001'
});
assert(finalizeOk.ok, 'finalization payload should be valid');

const finalizeBad = validateImportBatchFinalizationPayload7G({});
assert(!finalizeBad.ok, 'finalization without import_batch_id should be invalid');

console.log(JSON.stringify({
  ok: true,
  tests: {
    rowRange: rowRange.ok,
    missingKeysRejected: !missingKeys.ok,
    finalizeOk: finalizeOk.ok,
    finalizeBadRejected: !finalizeBad.ok
  }
}, null, 2));
