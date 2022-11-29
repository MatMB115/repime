import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobx/mobx.dart';
import 'package:repime/app/blocs/locador/db/locador_db.dart';
import 'package:repime/app/blocs/locador/locador.dart';
import 'package:repime/app/blocs/locatario/db/locatario_db.dart';
import 'package:repime/app/blocs/locatario/locatario.dart';
import 'package:repime/app/blocs/residencia/blocs/endereco/endereco.dart';
import 'package:repime/app/blocs/residencia/blocs/republica/db/republica_db.dart';
import 'package:repime/app/blocs/residencia/blocs/republica/republica.dart';
import 'package:repime/app/blocs/residencia/db/residencia_db.dart';
import 'package:repime/app/blocs/residencia/residencia.dart';
import 'package:repime/app/blocs/util/enum_tipos_residencia/enum_tipo_residencia.dart';
import 'package:repime/app/blocs/util/enum_tipos_residencia/store_enum/store_enum_tipo_residencia.dart';
import 'package:repime/app/pages/controller/main_controller.dart';
import '../../../global_widgets/snack_bar_app/snack_bar_app.dart';

part 'ctr_registrar_locador_page.g.dart';

// ignore: library_private_types_in_public_api
class CtrRegistrarLocadorPage = _CtrRegistrarLocadorPageBase with _$CtrRegistrarLocadorPage;

abstract class _CtrRegistrarLocadorPageBase with Store {
  @observable
  int atualIndex = 0;

  @action
  void _setIndex(int value) => atualIndex = value;

  // PARTE 1

  @observable
  var formFieldParte1 = GlobalKey<FormState>();

  @observable
  var keyScaffold = GlobalKey<ScaffoldState>();

  @observable
  var ctrTextNome = TextEditingController();

  @observable
  bool loading = false;

  @action
  _setLoading(bool value) => loading = value;

  String? validatorNome(String? value) {
    if (value!.isEmpty) return 'Insira um nome de usuário';
    return null;
  }

  @observable
  var ctrTextSenha = TextEditingController();

  String? validatorSenha(String? value) {
    if (value!.isEmpty) return 'Insira uma senha';
    if (value.length < 8) return 'Insira uma senha com, no mínimo, 8 caracteres';
    return null;
  }

  @observable
  bool obscureSenha = true;

  @action
  void _setObscureSenha() => obscureSenha = !obscureSenha;

  @action
  void onTapIconSenha() => _setObscureSenha();

  @observable
  var ctrTextContato = TextEditingController();

  @computed
  bool get isShowContinueParte1 => ctrTextNome.text.length > 0 && ctrTextSenha.text.length > 0;

  @action
  onTapContinue() async {
    if (!(formFieldParte1.currentState!.validate())) return;
    _setLoading(true);
    var existsUser = await LocadorDB.existsUsername(ctrTextNome.text);
    _setLoading(false);
    if (existsUser) {
      return ScaffoldMessenger.of(keyScaffold.currentContext!).showSnackBar(
          SnackBarApp.show(text: 'Nome de usuário já está em uso', context: keyScaffold.currentContext!));
    }
    _setIndex(1);
  }

  // PARTE 2
  @action
  void voltarFromParte2() => _setIndex(0);

  @action
  void continueFromParte2() => _setIndex(3);

  @observable
  XFile? image;

  @action
  Future<void> getImage() async {
    var result = await ImagePicker().pickImage(source: ImageSource.gallery, maxHeight: 300, maxWidth: 300);
    if (result == null) return;
    image = result;
  }

  @action
  void removeImage() => image = null;

  // PARTE 3
  @observable
  var tiposResidencia = [for (var e in EnumTiposResidencia.values) EnumTipoResidenciaStore(e)].asObservable();

  @action
  void onTapTipoResidencia(EnumTipoResidenciaStore t) {
    for (var e in tiposResidencia) {
      if (e.isSelected) {
        e.setSelect(false);
        break;
      }
    }
    t.setSelect();
  }

  @action
  void voltarFromParte3() => _setIndex(1);

  @computed
  bool get isShowContinueParte3 => tiposResidencia.any((t) => t.isSelected);

  @action
  void onTapContinueParte3() {
    var tipo = tiposResidencia.firstWhere((t) => t.isSelected);
    _setIndex(4);
  }

  @computed
  bool get isRepublica =>
      tiposResidencia.firstWhere((e) => e.isSelected).tipo == EnumTiposResidencia.replublica;

  // PARTE 4

  @observable
  var formFieldParte4 = GlobalKey<FormState>();

  @observable
  var ctrNomeRepublica = TextEditingController();

  @action
  String? validatorNomeRepublica(String? value) {
    if (value!.isEmpty) return 'Insira o nome de sua república';
    return null;
  }

  @observable
  var ctrEnderecoResidencia = TextEditingController();

  @action
  String? validatorEnderecoResidencia(String? value) {
    if (value!.isEmpty) return 'Insira o endereço da sua república';
    return null;
  }

  @observable
  var ctrFundacaoAno = TextEditingController();

  @action
  String? validatorFundacaoAno(String? value) {
    if (value!.isEmpty) return ' ';
    if (int.parse(value) < 0 || int.parse(value) > 2100) return '';
    return null;
  }

  @observable
  var ctrFundacaoMes = TextEditingController();

  @action
  String? validatorFundacaoMes(String? value) {
    if (value!.isEmpty) return '';
    if (int.parse(value) < 0 || int.parse(value) > 12) return '';
    return null;
  }

  @observable
  var ctrFundacaoDia = TextEditingController();

  @action
  String? validatorFundacaoDia(String? value) {
    if (value!.isEmpty) return '';
    if (int.parse(value) < 0 || int.parse(value) > 31) return '';
    return null;
  }

  @action
  onTapContinue4() async {
    if (!formFieldParte4.currentState!.validate()) return;
    // TODO: voltar aqui e fazer uma transacao sql
    try {
      _setLoading(true);
      var locador = Locador(
          id: 8,
          contato: ctrTextContato.text,
          nome: ctrTextNome.text,
          senha: ctrTextSenha.text,
          foto: image == null ? null : base64Encode(await image!.readAsBytes()));

      await LocadorDB.inserirInDB(locador);

      var cidade = Modular.get<MainController>().locatarioAtual.cidade;

      var residencia = Residencia(
          cidade: cidade,
          id: 0,
          tipo: tiposResidencia.firstWhere((e) => e.isSelected).tipo,
          endereco: Endereco(endereco: ctrEnderecoResidencia.text, lat: 0, log: 0));

      await ResidenciaDB.inserirResidencia(residencia, locador);

      if (!isRepublica) return _setLoading(false);

      var rep = Republica(
          cidade: residencia.cidade,
          id: 0,
          tipo: residencia.tipo,
          endereco: residencia.endereco,
          dateFundacao: DateTime.parse('${ctrFundacaoAno.text}${ctrFundacaoMes.text}${ctrFundacaoDia.text}'),
          nome: ctrNomeRepublica.text,
          isTrote: true);

      await RepublicaDB.inserirRepublica(rep);
      _setLoading(false);
    } on Exception catch (e) {
      _setLoading(false);
    }
  }

  @action
  onTapVoltar4() {
    _setIndex(3);
  }
}
