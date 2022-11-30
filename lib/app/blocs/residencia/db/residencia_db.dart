import 'package:repime/app/blocs/cidade/db/cidade_db.dart';
import 'package:repime/app/blocs/connection_database/connection_database.dart';
import 'package:repime/app/blocs/residencia/blocs/endereco/db/endereco_db.dart';
import 'package:repime/app/blocs/residencia/residencia.dart';

import '../../locador/locador.dart';
import '../../util/enum_tipos_residencia/enum_tipo_residencia.dart';

class ResidenciaDB extends Residencia {
  ResidenciaDB({required super.cidade, required super.id, required super.tipo, required super.endereco});

  static getAll(Locador locador) async {
    var r = await ConnectionDataBase().make(
      QueryDataBase(
          commandSQL:
              'SELECT r.id, r.tipo, r.id_locador, r.id_cidade, (endereco).latitude, (endereco).longitude , (endereco).endereco  ,c.*, l.* FROM residencia as r JOIN cidade as c ON c.id = r.id_cidade JOIN locador l ON l.id = r.id_locador WHERE r.id_locador = @idLocador',
          arguments: {'idLocador': locador.id}),
    );
    return ResidenciaDB.fromJson(r[0]);
  }

  static insercaoRepublica({required Locador locador, required Residencia residencia}) async =>
      await ConnectionDataBase().make(QueryDataBase(commandSQL: """
    SELECT  * FROM adiciona_locador_residencia( @nomeL, @senhaL, @contatoL, @fotoL, @idCidade, @tipoR, @lat, @long, @endr )
 """, arguments: {
        'nomeL': locador.nome,
        'senhaL': locador.senha,
        'contatoL': locador.contato,
        'fotoL': locador.foto,
        'idCidade': residencia.cidade.id,
        'tipoR': residencia.tipo.toNameDB(),
        'lat': residencia.endereco.lat,
        'long': residencia.endereco.log,
        'endr': residencia.endereco.endereco,
      }));

  static Future<void> inserirResidencia(Residencia residencia, Locador locador) async {
    await ConnectionDataBase().make(QueryDataBase(
        commandSQL:
            'INSERT INTO residencia (tipo, id_locador, id_cidade, endereco) VALUES (@tipo_r, @id_l, @id_c, ROW(@lat, @long, @end))',
        arguments: {
          'tipo_r': residencia.tipo.toNameDB(),
          'id_l': locador.id,
          'id_c': residencia.cidade.id,
          'lat': residencia.endereco.lat,
          'long': residencia.endereco.lat,
          'end': residencia.endereco.endereco
        }));
  }

  factory ResidenciaDB.fromJson(j) => ResidenciaDB(
      cidade: CidadeDB.fromJson(j),
      id: j['residencia']['id'],
      tipo: EnumTiposResidencia.fromJson(j['residencia']),
      endereco: EnderecoDB.fromJson(j));

  toJson() => {
        'residencia': {'id': id, 'tipo': tipo.toJson(), 'cidade': CidadeDB.toDB(cidade).toJson()}
      };

  static ResidenciaDB toDB(Residencia r) =>
      ResidenciaDB(cidade: r.cidade, endereco: r.endereco, id: r.id, tipo: r.tipo);
}
