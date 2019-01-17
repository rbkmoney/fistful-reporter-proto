include "base.thrift"

namespace java com.rbkmoney.fistful.reporter
namespace erlang fistful_reporter

typedef base.Timestamp Timestamp
typedef i64 ReportID
typedef base.ID FileID
typedef base.ID PartyID
typedef base.ID ContractID
typedef string ReportType

/**
 * Исключение, сигнализирующее о непригодных с точки зрения бизнес-логики входных данных
 */
exception InvalidRequest {
    /** Список пригодных для восприятия человеком ошибок во входных данных */
    1: required list<string> errors
}

/**
* Ошибка превышения максимального размера блока данных, доступного для отправки клиенту.
* limit - текущий максимальный размер блока.
*/
exception DatasetTooBig {
    1: i32 limit
}

exception PartyNotFound {}
exception ContractNotFound {}
exception ReportNotFound {}
exception FileNotFound {}

struct ReportRequest {
    1: required PartyID party_id
    2: required ContractID contract_id
    3: required ReportTimeRange time_range
}

/**
* Диапазон времени отчетов.
* from_time (inclusive) - начальное время.
* to_time (exclusive) - конечное время.
* Если from > to  - диапазон считается некорректным.
*/
struct ReportTimeRange {
    1: required Timestamp from_time
    2: required Timestamp to_time
}

/**
* Данные по отчету
* report_id - уникальный идентификатор отчета
* time_range - за какой период данный отчет
* report_type - тип отчета
* file_ids - id файлов данного отчета
*/
struct Report {
    1: required ReportID report_id
    2: required ReportTimeRange time_range
    3: required Timestamp created_at
    4: required ReportType report_type
    5: required ReportStatus status
    6: optional list<FileID> file_ids
}

/**
* Статусы отчета
*/
enum ReportStatus {
    // в обработке
    pending
    // создан
    created
    // отменен
    canceled
}

service Reporting {

  /**
  * Получить список отчетов по контракту за указанный промежуток времени с фильтрацией по типу
  * В случае если список report_types пустой, фильтрации по типу не будет
  * Возвращает список отчетов или пустой список, если отчеты по магазину не найдены
  *
  * InvalidRequest, если промежуток времени некорректен
  * DatasetTooBig, если размер списка превышает допустимый лимит
  */
  list<Report> GetReports(1: ReportRequest request, 2: list<ReportType> report_types) throws (1: DatasetTooBig ex1, 2: InvalidRequest ex2)

  /**
  * Сгенерировать отчет с указанным типом по магазину за указанный промежуток времени
  * Возвращает идентификатор отчета
  *
  * PartyNotFound, если party не найден
  * ContractNotFound, если contract не найден
  * InvalidRequest, если промежуток времени некорректен
  */
  ReportID GenerateReport(1: ReportRequest request, 2: ReportType report_type) throws (1: PartyNotFound ex1, 2: ContractNotFound ex2, 3: InvalidRequest ex3)

  /**
  * Запрос на получение отчета
  *
  * ReportNotFound, если отчет не найден
  */
  Report GetReport(1: PartyID party_id, 2: ContractID contract_id, 3: ReportID report_id) throws (1: ReportNotFound ex1)

  /**
  * Запрос на отмену отчета
  *
  * ReportNotFound, если отчет не найден
  */
  void CancelReport(1: PartyID party_id, 2: ContractID contract_id, 3: ReportID report_id) throws (1: ReportNotFound ex1)

}
