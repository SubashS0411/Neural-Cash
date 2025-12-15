import { Router } from 'express';
import { createTrip, listTrips } from '../services/tripsService.js';

const router = Router();
const getUserId = (req) => req.headers['x-user-id'];

router.get('/', async (req, res, next) => {
  try {
    const data = await listTrips(getUserId(req));
    res.json({ status: 'success', data });
  } catch (err) {
    next(err);
  }
});

router.post('/', async (req, res, next) => {
  try {
    const data = await createTrip(getUserId(req), req.body);
    res.json({ status: 'success', data });
  } catch (err) {
    next(err);
  }
});

export default router;
