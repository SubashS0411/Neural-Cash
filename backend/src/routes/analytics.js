import { Router } from 'express';
import { getCrossCut, getPredictions, getSpendingReport, exportSpendingCsv } from '../services/analyticsService.js';

const router = Router();
function getUserId(req) {
  return req.headers['x-user-id'];
}

router.get('/cross-cut', async (req, res, next) => {
  try {
    const data = await getCrossCut(getUserId(req));
    res.json({ status: 'success', data });
  } catch (err) {
    next(err);
  }
});

router.get('/predictions', async (req, res, next) => {
  try {
    const data = await getPredictions(getUserId(req));
    res.json({ status: 'success', data });
  } catch (err) {
    next(err);
  }
});

router.get('/spending-report', async (req, res, next) => {
  try {
    const data = await getSpendingReport(getUserId(req), req.query);
    res.json({ status: 'success', data });
  } catch (err) {
    next(err);
  }
});

router.get('/export', async (req, res, next) => {
  try {
    const csv = await exportSpendingCsv(getUserId(req), req.query);
    res.setHeader('Content-Type', 'text/csv');
    res.setHeader('Content-Disposition', 'attachment; filename="transactions.csv"');
    res.send(csv);
  } catch (err) {
    next(err);
  }
});

export default router;
