import { Router } from 'express';
import { listCategories, createCategory, updateCategory } from '../services/categoriesService.js';

const router = Router();

function getUserId(req) {
  return req.headers['x-user-id'];
}

router.get('/', async (req, res, next) => {
  try {
    const data = await listCategories(getUserId(req));
    res.json({ status: 'success', data });
  } catch (err) {
    next(err);
  }
});

router.post('/', async (req, res, next) => {
  try {
    const data = await createCategory(getUserId(req), req.body);
    res.json({ status: 'success', data });
  } catch (err) {
    next(err);
  }
});

router.patch('/:id', async (req, res, next) => {
  try {
    const data = await updateCategory(req.params.id, req.body);
    res.json({ status: 'success', data });
  } catch (err) {
    next(err);
  }
});

export default router;
