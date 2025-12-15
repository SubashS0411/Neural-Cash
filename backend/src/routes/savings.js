import { Router } from 'express';
import { listGoals, createGoal, contributeGoal } from '../services/savingsService.js';

const router = Router();
const getUserId = (req) => req.headers['x-user-id'];

router.get('/goals', async (req, res, next) => {
  try {
    const data = await listGoals(getUserId(req));
    res.json({ status: 'success', data });
  } catch (err) {
    next(err);
  }
});

router.post('/goals', async (req, res, next) => {
  try {
    const data = await createGoal(getUserId(req), req.body);
    res.json({ status: 'success', data });
  } catch (err) {
    next(err);
  }
});

router.post('/goals/:id/contribute', async (req, res, next) => {
  try {
    const data = await contributeGoal(req.params.id, req.body.amount);
    res.json({ status: 'success', data });
  } catch (err) {
    next(err);
  }
});

export default router;
