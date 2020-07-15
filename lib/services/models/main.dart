import 'package:firestore_auth_crud/services/models/connected_models.dart';
import 'package:scoped_model/scoped_model.dart';

class MainModel extends Model with ConnectedModel, AuthModel {}
