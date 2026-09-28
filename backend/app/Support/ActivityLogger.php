<?php

namespace App\Support;

use Illuminate\Support\Facades\DB;

class ActivityLogger
{
    public static function record(
        ?int $userId,
        string $action,
        string $table,
        ?int $recordId,
        string $description,
        ?string $ipAddress = null,
    ): void {
        DB::table('tbl_activityLog')->insert([
            'v_userId' => $userId,
            'v_actionType' => $action,
            'v_tableName' => $table,
            'v_recordId' => $recordId,
            'v_actionDescription' => $description,
            'v_ipAddress' => $ipAddress,
        ]);
    }
}
