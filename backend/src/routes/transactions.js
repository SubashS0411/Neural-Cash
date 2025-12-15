import { Router } from 'express';
import multer from 'multer';
import {
  addTransaction,
  bulkImport,
  listTransactions,
  approveTransaction,
  recategorize,
  softDelete,
} from '../services/transactionsService.js';
import { parseReceipt } from '../services/ocrService.js';
import { uploadReceipt } from '../services/storageService.js';

const upload = multer({ storage: multer.memoryStorage() });
const router = Router();

router.get('/', async (req, res, next) => {
  try {
    const data = await listTransactions(req.user.id, req.query);
    res.json({ status: 'success', data });
  } catch (err) {
    next(err);
  }
});

router.post('/add', async (req, res, next) => {
  try {
    const data = await addTransaction(req.user.id, req.body);
    res.json({ status: 'success', data });
  } catch (err) {
    next(err);
  }
});

router.post('/bulk-import', upload.single('file'), async (req, res, next) => {
  try {
    const csvString = req.file?.buffer?.toString();
    const data = await bulkImport(req.user.id, csvString ?? '');
    res.json({ status: 'success', data });
  } catch (err) {
    next(err);
  }
});

router.post('/receipt', upload.single('receipt'), async (req, res, next) => {
  try {
    const parsed = await parseReceipt(req.file.buffer);
    const uploaded = await uploadReceipt(req.user.id, req.file);
    res.json({ status: 'success', data: { ...parsed, receipt_url: uploaded.publicUrl } });
  } catch (err) {
    next(err);
  }
});

router.patch('/:id/approve', async (req, res, next) => {
  try {
    const data = await approveTransaction(req.params.id, req.body.action);
    res.json({ status: 'success', data });
  } catch (err) {
    next(err);
  }
});

router.patch('/:id/recategorize', async (req, res, next) => {
  try {
    const data = await recategorize(req.params.id, req.body);
    res.json({ status: 'success', data });
  } catch (err) {
    next(err);
  }
});

router.delete('/:id', async (req, res, next) => {
  try {
    const data = await softDelete(req.params.id);
    res.json({ status: 'success', data });
  } catch (err) {
    next(err);
  }
});

export default router;
